const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const morgan = require('morgan');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const https = require('https');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Razorpay = require('razorpay');
require('dotenv').config();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }
});

const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET || 'tapovana_fallback_secret';

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));
app.use('/uploads', express.static(uploadsDir));

// ─── PostgreSQL Pool ──────────────────────────────────────────────────────────
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

// ─── Nodemailer transporter ──────────────────────────────────────────────────
let transporter = null;
const emailSender = process.env.EMAIL_USER || process.env.BREVO_EMAIL;

if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
  transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });
  console.log('📧 Gmail email transporter configured for:', process.env.EMAIL_USER);
} else if (process.env.BREVO_EMAIL && process.env.BREVO_SMTP_KEY) {
  transporter = nodemailer.createTransport({
    host: 'smtp-relay.brevo.com',
    port: 587,
    secure: false,
    auth: {
      user: process.env.BREVO_EMAIL,
      pass: process.env.BREVO_SMTP_KEY,
    },
  });
  console.log('📧 Brevo email transporter configured for:', process.env.BREVO_EMAIL);
} else {
  console.log('⚠️  No email credentials set — OTPs will be logged to console only.');
}

// ─── Send OTP helper ──────────────────────────────────────────────────────────
async function sendOtpEmail(email, otp, purpose) {
  const subject = purpose === 'signup'
    ? 'Tapovana — Verify your email'
    : (purpose === 'reset_password' ? 'Tapovana — Reset your password' : 'Tapovana — Login OTP');
  const html = `
    <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;border:1px solid #e2e8f0;border-radius:12px">
      <h2 style="color:#58B814">Tapovana Wellness</h2>
      <p>Your one-time password is:</p>
      <div style="font-size:36px;font-weight:bold;letter-spacing:8px;color:#1e293b;padding:16px;background:#f8fafc;border-radius:8px;text-align:center">${otp}</div>
      <p style="color:#64748b;font-size:13px">This OTP expires in <strong>10 minutes</strong>. Do not share it with anyone.</p>
    </div>
  `;

  // 1. Try Resend HTTP API (Recommended for Render Free Tier)
  if (process.env.RESEND_API_KEY) {
    return new Promise((resolve, reject) => {
      const data = JSON.stringify({
        from: 'onboarding@resend.dev',
        to: email,
        subject: subject,
        html: html,
      });

      const options = {
        hostname: 'api.resend.com',
        port: 443,
        path: '/emails',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
          'Content-Length': Buffer.byteLength(data),
        },
      };

      const req = https.request(options, (res) => {
        let responseBody = '';
        res.on('data', (chunk) => { responseBody += chunk; });
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            console.log(`📧 OTP sent via Resend API to ${email}`);
            resolve();
          } else {
            console.error('❌ Resend API Error Response:', responseBody);
            reject(new Error(`Resend API returned status ${res.statusCode}`));
          }
        });
      });

      req.on('error', (err) => {
        console.error('❌ Resend HTTP request error:', err);
        reject(err);
      });

      req.write(data);
      req.end();
    });
  }

  // 2. Try Nodemailer SMTP (Gmail / Brevo)
  if (transporter && emailSender) {
    await transporter.sendMail({
      from: `"Tapovana Wellness" <${emailSender}>`,
      to: email,
      subject,
      html,
    });
    console.log(`📧 OTP sent to ${email}`);
  } else {
    // Fallback: log to console (visible in Render logs)
    console.log(`\n🔐 ===== OTP FOR ${email} =====`);
    console.log(`   OTP: ${otp}`);
    console.log(`   Purpose: ${purpose}`);
    console.log(`================================\n`);
  }
}

// ─── Generate 6-digit OTP ─────────────────────────────────────────────────────
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ─── JWT helper ───────────────────────────────────────────────────────────────
function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: '30d' });
}

// ─── Database Init ────────────────────────────────────────────────────────────
async function initDatabase() {
  const client = await pool.connect();
  try {
    console.log('🔌 Connected to Neon PostgreSQL database.');

    // Bookings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS service_bookings (
        id SERIAL PRIMARY KEY,
        user_name VARCHAR(255) NOT NULL,
        profile_pic TEXT,
        service_name VARCHAR(255) NOT NULL,
        booking_date DATE NOT NULL,
        booking_time VARCHAR(50) NOT NULL,
        therapist_name VARCHAR(255) NOT NULL,
        note TEXT,
        total_amount VARCHAR(100) NOT NULL,
        pass_details VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Auto-migrate service_bookings table
    await client.query(`
      ALTER TABLE service_bookings ADD COLUMN IF NOT EXISTS email VARCHAR(255);
    `);

    // Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash TEXT,
        google_uid TEXT,
        provider VARCHAR(50) DEFAULT 'email',
        name VARCHAR(255),
        gender VARCHAR(50),
        city VARCHAR(255),
        address TEXT,
        phone VARCHAR(50),
        dob DATE,
        health_concerns TEXT,
        preferred_therapies TEXT,
        allergies TEXT,
        membership VARCHAR(100) DEFAULT 'FREE',
        profile_photo_url TEXT,
        two_step_verification BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Auto-migrate users table if it already existed but was missing columns
    await client.query(`
      ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
      ALTER TABLE users ADD COLUMN IF NOT EXISTS google_uid TEXT;
      ALTER TABLE users ADD COLUMN IF NOT EXISTS provider VARCHAR(50) DEFAULT 'email';
    `);

    // OTP codes table
    await client.query(`
      CREATE TABLE IF NOT EXISTS otp_codes (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        otp VARCHAR(6) NOT NULL,
        purpose VARCHAR(20) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        used BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // User memberships table
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_memberships (
        user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        membership_name VARCHAR(255) NOT NULL DEFAULT 'FREE',
        purchase_date DATE,
        available_credits INT NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Vedic Package Memberships table
    await client.query(`
      CREATE TABLE IF NOT EXISTS vedic_package_memberships (
        id SERIAL PRIMARY KEY,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        user_name VARCHAR(255),
        email VARCHAR(255),
        profile_pic TEXT,
        membership_name VARCHAR(255) NOT NULL,
        join_date DATE NOT NULL,
        join_time VARCHAR(50) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Razorpay Transactions table
    await client.query(`
      CREATE TABLE IF NOT EXISTS razorpay_transactions (
        id SERIAL PRIMARY KEY,
        payment_id VARCHAR(255) NOT NULL,
        order_id VARCHAR(255) NOT NULL,
        signature VARCHAR(255),
        payment_method VARCHAR(50),
        service_name VARCHAR(255),
        amount DECIMAL(10,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    // Auto-add new columns if the table already exists
    await client.query(`
      ALTER TABLE razorpay_transactions 
      ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50),
      ADD COLUMN IF NOT EXISTS service_name VARCHAR(255),
      ADD COLUMN IF NOT EXISTS amount DECIMAL(10,2);
    `);

    // Workshop Enrollments table
    await client.query(`
      CREATE TABLE IF NOT EXISTS workshop_enrollments (
        id SERIAL PRIMARY KEY,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        username VARCHAR(255),
        email VARCHAR(255),
        profile_pic TEXT,
        workshop_name VARCHAR(255) NOT NULL,
        pass_name VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Reviews table
    await client.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id SERIAL PRIMARY KEY,
        username VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        module_type VARCHAR(50) NOT NULL,
        title VARCHAR(255) NOT NULL,
        rating INT NOT NULL,
        feedback TEXT NOT NULL,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log('✅ All tables are ready.');
  } catch (err) {
    console.error('❌ Database initialization failed:', err);
    process.exit(1);
  } finally {
    client.release();
  }
}

initDatabase();

// ═══════════════════════════════════════════════════════════════════════════════
//   HEALTH CHECKS
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Tapovana Backend is running.' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Tapovana Backend is healthy.' });
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — SIGNUP: SEND OTP
//   Body: { email, password } OR { email, provider: "google" }
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/auth/signup/send-otp', async (req, res) => {
  const { email, password, provider } = req.body;

  if (!email) return res.status(400).json({ success: false, message: 'Email is required.' });

  try {
    // Check if user already exists
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);

    if (provider === 'google') {
      // Google signup — no OTP needed, just check existence
      if (existing.rows.length > 0) {
        return res.json({ success: true, exists: true, message: 'User already exists.' });
      }
      return res.json({ success: true, exists: false, message: 'User does not exist.' });
    }

    // Email signup
    if (existing.rows.length > 0) {
      return res.status(409).json({ success: false, message: 'An account with this email already exists.' });
    }

    if (!password) return res.status(400).json({ success: false, message: 'Password is required.' });

    // Generate & store OTP
    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    await pool.query(
      'INSERT INTO otp_codes (email, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)',
      [email, otp, 'signup', expiresAt]
    );

    await sendOtpEmail(email, otp, 'signup');

    return res.json({ success: true, message: 'OTP sent to your email.' });
  } catch (err) {
    console.error('❌ send-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — SIGNUP: VERIFY OTP
//   Body: { email, otp }
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/auth/signup/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) return res.status(400).json({ success: false, message: 'Email and OTP are required.' });

  try {
    const result = await pool.query(
      `SELECT * FROM otp_codes
       WHERE email = $1 AND otp = $2 AND purpose = 'signup'
         AND used = false AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [email, otp]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP.' });
    }

    // Mark OTP as used
    await pool.query('UPDATE otp_codes SET used = true WHERE id = $1', [result.rows[0].id]);

    return res.json({ success: true, message: 'OTP verified.' });
  } catch (err) {
    console.error('❌ verify-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — FORGOT PASSWORD: SEND OTP
//   Body: { email }
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/auth/forgot-password/send-otp', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ success: false, message: 'Email is required.' });

  try {
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No account found with this email.' });
    }

    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    await pool.query(
      'INSERT INTO otp_codes (email, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)',
      [email, otp, 'reset_password', expiresAt]
    );

    await sendOtpEmail(email, otp, 'reset_password');

    return res.json({ success: true, message: 'OTP sent to your email.' });
  } catch (err) {
    console.error('❌ forgot-password/send-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — FORGOT PASSWORD: VERIFY OTP
//   Body: { email, otp }
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/auth/forgot-password/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) return res.status(400).json({ success: false, message: 'Email and OTP are required.' });

  try {
    const result = await pool.query(
      `SELECT * FROM otp_codes
       WHERE email = $1 AND otp = $2 AND purpose = 'reset_password'
         AND used = false AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [email, otp]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP.' });
    }

    await pool.query('UPDATE otp_codes SET used = true WHERE id = $1', [result.rows[0].id]);
    return res.json({ success: true, message: 'OTP verified. You can now reset your password.' });
  } catch (err) {
    console.error('❌ forgot-password/verify-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — FORGOT PASSWORD: RESET PASSWORD
//   Body: { email, new_password }
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/auth/forgot-password/reset', async (req, res) => {
  const { email, new_password } = req.body;
  if (!email || !new_password) return res.status(400).json({ success: false, message: 'Email and new password are required.' });

  try {
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const passwordHash = await bcrypt.hash(new_password, 10);
    await pool.query('UPDATE users SET password_hash = $1 WHERE email = $2', [passwordHash, email]);

    return res.json({ success: true, message: 'Password reset successfully. Please login with your new password.' });
  } catch (err) {
    console.error('❌ forgot-password/reset error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — SIGNUP: COMPLETE
//   Email body: { email, password, name, gender, city }
//   Google body: { email, uid, provider: "google", name, gender, city }
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/auth/signup/complete', async (req, res) => {
  const { email, password, uid, provider, name, gender, city } = req.body;

  if (!email || !name) {
    return res.status(400).json({ success: false, message: 'Email and name are required.' });
  }

  try {
    // Check not already registered
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ success: false, message: 'User already exists.' });
    }

    let passwordHash = null;
    if (provider !== 'google') {
      if (!password) return res.status(400).json({ success: false, message: 'Password is required.' });
      passwordHash = await bcrypt.hash(password, 10);
    }

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, google_uid, provider, name, gender, city)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, email, name, gender, city, membership, created_at`,
      [email, passwordHash, uid || null, provider || 'email', name, gender || null, city || null]
    );

    const user = result.rows[0];
    const token = generateToken(user.id);

    return res.status(201).json({
      success: true,
      message: 'Account created successfully.',
      token,
      user,
    });
  } catch (err) {
    console.error('❌ signup/complete error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — LOGIN
//   Email body: { email, password }
//   Google body: { email, uid, provider: "google" }
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/auth/login', async (req, res) => {
  const { email, password, uid, provider } = req.body;

  if (!email) return res.status(400).json({ success: false, message: 'Email is required.' });

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No account found with this email.' });
    }

    const user = result.rows[0];

    // Google login
    if (provider === 'google') {
      const token = generateToken(user.id);
      return res.json({
        success: true,
        requires_otp: false,
        token,
        user: { id: user.id, email: user.email, name: user.name },
      });
    }

    // Email login — verify password
    if (!password) return res.status(400).json({ success: false, message: 'Password is required.' });

    const passwordMatch = await bcrypt.compare(password, user.password_hash || '');
    if (!passwordMatch) {
      return res.status(401).json({ success: false, message: 'Incorrect password.' });
    }

    // Check if 2FA is enabled
    if (user.two_step_verification) {
      const otp = generateOtp();
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
      await pool.query(
        'INSERT INTO otp_codes (email, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)',
        [email, otp, 'login', expiresAt]
      );
      await sendOtpEmail(email, otp, 'login');

      return res.json({
        success: true,
        requires_otp: true,
        message: 'OTP sent to your email for 2FA.',
      });
    }

    const token = generateToken(user.id);
    return res.json({
      success: true,
      requires_otp: false,
      token,
      user: { id: user.id, email: user.email, name: user.name },
    });
  } catch (err) {
    console.error('❌ login error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — LOGIN: VERIFY OTP (2FA)
//   Body: { email, otp }
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/auth/login/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) return res.status(400).json({ success: false, message: 'Email and OTP are required.' });

  try {
    const otpResult = await pool.query(
      `SELECT * FROM otp_codes
       WHERE email = $1 AND otp = $2 AND purpose = 'login'
         AND used = false AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [email, otp]
    );

    if (otpResult.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP.' });
    }

    await pool.query('UPDATE otp_codes SET used = true WHERE id = $1', [otpResult.rows[0].id]);

    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = userResult.rows[0];
    const token = generateToken(user.id);

    return res.json({
      success: true,
      token,
      user: { id: user.id, email: user.email, name: user.name },
    });
  } catch (err) {
    console.error('❌ login/verify-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   AUTH — TWO-STEP STATUS
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/api/auth/two-step/status/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query('SELECT two_step_verification FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });
    return res.json({ success: true, two_step_verification: result.rows[0].two_step_verification });
  } catch (err) {
    console.error('❌ two-step/status error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

app.post('/api/auth/two-step/toggle', async (req, res) => {
  const { id, enabled } = req.body;
  if (!id) return res.status(400).json({ success: false, message: 'User ID is required.' });
  try {
    await pool.query('UPDATE users SET two_step_verification = $1 WHERE id = $2', [enabled, id]);
    return res.json({ success: true, message: `2FA ${enabled ? 'enabled' : 'disabled'}.` });
  } catch (err) {
    console.error('❌ two-step/toggle error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER DETAILS — GET
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/api/details/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query(
      `SELECT id, email, name, gender, city, address, phone, dob,
              health_concerns, preferred_therapies, allergies,
              membership, profile_photo_url, two_step_verification, created_at
       FROM users WHERE id = $1`,
      [userId]
    );
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });
    return res.json({ success: true, user: result.rows[0] });
  } catch (err) {
    console.error('❌ GET /api/details error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER DETAILS — PATCH (update personal info)
// ═══════════════════════════════════════════════════════════════════════════════

app.patch('/api/details/:userId', async (req, res) => {
  const { userId } = req.params;
  const { name, email, phone, dob, gender, city, address, health_concerns, preferred_therapies, allergies } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users SET
        name = COALESCE($1, name),
        email = COALESCE($2, email),
        phone = COALESCE($3, phone),
        dob = COALESCE($4::DATE, dob),
        gender = COALESCE($5, gender),
        city = COALESCE($6, city),
        address = COALESCE($7, address),
        health_concerns = COALESCE($8, health_concerns),
        preferred_therapies = COALESCE($9, preferred_therapies),
        allergies = COALESCE($10, allergies)
       WHERE id = $11
       RETURNING id, email, name, gender, city, address, phone, dob,
                 health_concerns, preferred_therapies, allergies, membership, profile_photo_url`,
      [name, email, phone, dob || null, gender, city, address, health_concerns, preferred_therapies, allergies, userId]
    );

    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });

    return res.json({ success: true, message: 'Profile updated.', user: result.rows[0] });
  } catch (err) {
    console.error('❌ PATCH /api/details error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER DETAILS — PATCH profile photo
// ═══════════════════════════════════════════════════════════════════════════════

app.patch('/api/details/:userId/profile-photo', upload.single('profile_photo'), async (req, res) => {
  const { userId } = req.params;

  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file uploaded.' });
    }

    const profile_photo_url = `/uploads/${req.file.filename}`;

    const result = await pool.query(
      'UPDATE users SET profile_photo_url = $1 WHERE id = $2 RETURNING profile_photo_url',
      [profile_photo_url, userId]
    );

    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });

    return res.json({
      success: true,
      message: 'Profile photo updated.',
      data: { profile_photo_url: result.rows[0].profile_photo_url },
    });
  } catch (err) {
    console.error('❌ PATCH /profile-photo error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER DETAILS — DELETE profile photo
// ═══════════════════════════════════════════════════════════════════════════════

app.delete('/api/details/:userId/profile-photo', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query(
      'UPDATE users SET profile_photo_url = NULL WHERE id = $1 RETURNING id',
      [userId]
    );
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });
    return res.json({ success: true, message: 'Profile photo deleted.' });
  } catch (err) {
    console.error('❌ DELETE /profile-photo error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   BOOKINGS — POST
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/bookings', async (req, res) => {
  const { userName, email, profilePic, serviceName, bookingDate, bookingTime, note, totalAmount, passDetails } = req.body;

  if (!userName || !serviceName || !bookingDate || !bookingTime || !totalAmount) {
    return res.status(400).json({ error: 'Missing required fields.' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO service_bookings (user_name, email, profile_pic, service_name, booking_date, booking_time, therapist_name, note, total_amount, pass_details)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING id, created_at`,
      [userName, email || null, profilePic || null, serviceName, bookingDate, bookingTime, "Not Assigned", note || null, totalAmount, passDetails || null]
    );

    return res.status(201).json({
      success: true,
      message: 'Booking saved.',
      bookingId: result.rows[0].id,
      createdAt: result.rows[0].created_at,
    });
  } catch (err) {
    console.error('❌ POST /api/bookings error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   REVIEWS — POST
// ═══════════════════════════════════════════════════════════════════════════════

app.post('/api/reviews', async (req, res) => {
  const { username, email, module_type, title, rating, feedback, date } = req.body;

  if (!username || !email || !module_type || !title || !rating || !feedback) {
    return res.status(400).json({ error: 'Missing required fields.' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO reviews (username, email, module_type, title, rating, feedback, date)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, date`,
      [username, email, module_type, title, rating, feedback, date || new Date()]
    );

    return res.status(201).json({
      success: true,
      message: 'Review saved.',
      reviewId: result.rows[0].id,
    });
  } catch (err) {
    console.error('❌ POST /api/reviews error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   REVIEWS — GET ALL
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/api/reviews', async (req, res) => {
  const { module_type, title } = req.query;
  try {
    let result;
    if (module_type && title) {
      result = await pool.query('SELECT * FROM reviews WHERE module_type = $1 AND title = $2 ORDER BY id DESC', [module_type, title]);
    } else if (module_type) {
      result = await pool.query('SELECT * FROM reviews WHERE module_type = $1 ORDER BY id DESC', [module_type]);
    } else {
      result = await pool.query('SELECT * FROM reviews ORDER BY id DESC');
    }
    return res.json({ success: true, count: result.rows.length, reviews: result.rows });
  } catch (err) {
    console.error('❌ GET /api/reviews error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   BOOKINGS — GET ALL (optional ?userName= filter)
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/api/bookings', async (req, res) => {
  const { userName } = req.query;
  try {
    let result;
    if (userName) {
      result = await pool.query('SELECT * FROM service_bookings WHERE user_name = $1 ORDER BY id DESC', [userName]);
    } else {
      result = await pool.query('SELECT * FROM service_bookings ORDER BY id DESC');
    }
    return res.json({ success: true, count: result.rows.length, bookings: result.rows });
  } catch (err) {
    console.error('❌ GET /api/bookings error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   BOOKINGS — GET SINGLE
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/api/bookings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM service_bookings WHERE id = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: `Booking ${id} not found.` });
    return res.json({ success: true, booking: result.rows[0] });
  } catch (err) {
    console.error('❌ GET /api/bookings/:id error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER MEMBERSHIPS — GET
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/api/membership', async (req, res) => {
  const { userId } = req.query;
  try {
    if (userId) {
      // Fetch details for a specific user
      const result = await pool.query(
        `SELECT 
          m.membership_name, 
          m.purchase_date, 
          m.available_credits, 
          u.name AS customer_name, 
          u.profile_photo_url AS profile_pic
         FROM user_memberships m
         JOIN users u ON m.user_id = u.id
         WHERE m.user_id = $1`,
        [userId]
      );

      if (result.rows.length === 0) {
        // Return default FREE membership if user exists
        const userCheck = await pool.query('SELECT name, profile_photo_url FROM users WHERE id = $1', [userId]);
        if (userCheck.rows.length === 0) {
          return res.status(404).json({ success: false, message: 'User not found.' });
        }
        return res.json({
          success: true,
          membership: {
            membership_name: 'FREE',
            purchase_date: null,
            available_credits: 0,
            customer_name: userCheck.rows[0].name,
            profile_pic: userCheck.rows[0].profile_photo_url
          }
        });
      }

      return res.json({ success: true, membership: result.rows[0] });
    } else {
      // Fetch all customer memberships
      const result = await pool.query(
        `SELECT 
          m.user_id,
          m.membership_name, 
          m.purchase_date, 
          m.available_credits, 
          u.name AS customer_name, 
          u.profile_photo_url AS profile_pic,
          u.email AS customer_email
         FROM user_memberships m
         JOIN users u ON m.user_id = u.id
         ORDER BY m.created_at DESC`
      );
      return res.json({ success: true, count: result.rows.length, memberships: result.rows });
    }
  } catch (err) {
    console.error('❌ GET /api/membership error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER MEMBERSHIPS — POST (SAVE/UPDATE)
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/membership', async (req, res) => {
  const { userId, membership_name, purchase_date, available_credits } = req.body;

  if (!userId) {
    return res.status(400).json({ success: false, message: 'User ID is required.' });
  }
  if (!membership_name) {
    return res.status(400).json({ success: false, message: 'Membership name is required.' });
  }

  try {
    // Check if user exists
    const userCheck = await pool.query('SELECT name, profile_photo_url FROM users WHERE id = $1', [userId]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    // Upsert membership details
    const result = await pool.query(
      `INSERT INTO user_memberships (user_id, membership_name, purchase_date, available_credits)
       VALUES ($1, $2, COALESCE($3, NOW()), COALESCE($4, 0))
       ON CONFLICT (user_id) DO UPDATE 
       SET membership_name = EXCLUDED.membership_name,
           purchase_date = EXCLUDED.purchase_date,
           available_credits = EXCLUDED.available_credits
       RETURNING *`,
      [userId, membership_name, purchase_date || null, available_credits || 0]
    );

    // Keep the users table membership column in sync
    await pool.query('UPDATE users SET membership = $1 WHERE id = $2', [membership_name, userId]);

    return res.json({
      success: true,
      message: 'Membership saved successfully.',
      membership: {
        membership_name: result.rows[0].membership_name,
        purchase_date: result.rows[0].purchase_date,
        available_credits: result.rows[0].available_credits,
        customer_name: userCheck.rows[0].name,
        profile_pic: userCheck.rows[0].profile_photo_url
      }
    });
  } catch (err) {
    console.error('❌ POST /api/membership error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   VEDIC PACKAGES — JOIN (POST)
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/vedic-packages/join', async (req, res) => {
  const { userName, email, profilePic, membership_name, join_date, join_time } = req.body;

  if (!userName || !membership_name || !join_date || !join_time) {
    return res.status(400).json({ success: false, message: 'Missing required fields: userName, membership_name, join_date, join_time' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO vedic_package_memberships (user_name, email, profile_pic, membership_name, join_date, join_time)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [userName, email || null, profilePic || null, membership_name, join_date, join_time]
    );

    return res.status(201).json({
      success: true,
      message: 'Successfully joined Vedic Package.',
      membership: result.rows[0]
    });
  } catch (err) {
    console.error('❌ POST /api/vedic-packages/join error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   VEDIC PACKAGES — GET MEMBERS
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/api/vedic-packages/members', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vedic_package_memberships ORDER BY created_at DESC');
    return res.json({ success: true, count: result.rows.length, members: result.rows });
  } catch (err) {
    console.error('❌ GET /api/vedic-packages/members error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   WORKSHOPS — GET ENROLLMENTS
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/api/workshops/enroll', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM workshop_enrollments ORDER BY created_at DESC');
    return res.json({ success: true, count: result.rows.length, enrollments: result.rows });
  } catch (err) {
    console.error('❌ GET /api/workshops/enroll error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   WORKSHOPS — ENROLL (POST)
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/workshops/enroll', async (req, res) => {
  const { userName, email, profilePic, workshop_name, pass_name } = req.body;

  if (!userName || !workshop_name) {
    return res.status(400).json({ success: false, message: 'Missing required fields: userName, workshop_name' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO workshop_enrollments (username, email, profile_pic, workshop_name, pass_name)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userName, email || null, profilePic || null, workshop_name, pass_name || null]
    );

    return res.status(201).json({
      success: true,
      message: 'Successfully enrolled in the workshop.',
      enrollment: result.rows[0]
    });
  } catch (err) {
    console.error('❌ POST /api/workshops/enroll error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   PAYMENT TRANSACTIONS (POST)
// ═══════════════════════════════════════════════════════════════════════════════
app.post('/api/payment/transaction', async (req, res) => {
  const { payment_id, order_id, signature, amount, service_name } = req.body;

  if (!payment_id) {
    return res.status(400).json({ success: false, message: 'Missing payment_id' });
  }

  let paymentMethod = null;

  try {
    // Attempt to fetch payment details from Razorpay using the Key Secret
    if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
      const razorpay = new Razorpay({
        key_id: process.env.RAZORPAY_KEY_ID,
        key_secret: process.env.RAZORPAY_KEY_SECRET
      });
      const paymentDetails = await razorpay.payments.fetch(payment_id);
      paymentMethod = paymentDetails.method; // e.g., 'upi', 'card', 'netbanking'
    } else {
      console.warn("⚠️ RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET missing in .env. Cannot fetch payment method.");
    }
  } catch (rzpErr) {
    console.error('❌ Failed to fetch from Razorpay:', rzpErr);
    // Proceed to save the transaction anyway, just without the payment method
  }

  try {
    const result = await pool.query(
      `INSERT INTO razorpay_transactions (payment_id, order_id, signature, payment_method, service_name, amount)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [payment_id, order_id || '', signature || '', paymentMethod, service_name || null, amount || null]
    );

    return res.status(201).json({
      success: true,
      message: 'Transaction saved successfully.',
      transaction: result.rows[0]
    });
  } catch (err) {
    console.error('❌ POST /api/payment/transaction error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   PAYMENT TRANSACTIONS (GET) - Fetch all transactions
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/api/payment/transaction', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM razorpay_transactions ORDER BY created_at DESC');
    
    // Map the result to exactly match the requested fields
    const formattedTransactions = result.rows.map(tx => ({
      payment_id: tx.payment_id,
      service_name: tx.service_name || 'N/A',
      amount: tx.amount || 0.00,
      date_and_time_of_payment: tx.created_at,
      payment_method: tx.payment_method || 'N/A'
    }));

    return res.json({
      success: true,
      count: formattedTransactions.length,
      transactions: formattedTransactions
    });
  } catch (err) {
    console.error('❌ GET /api/payment/transaction error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   USER DATA (GET) - Fetch all users
// ═══════════════════════════════════════════════════════════════════════════════
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
    
    const users = result.rows.map(user => ({
      id: user.id || null,
      name: user.name || null,
      email: user.email || null,
      phone: user.phone || null,
      joined_date: user.created_at || null,
      status: 'active', // Default to active as there is no status column in DB
      profile_image_url: user.profile_photo_url || null,
      pass_name: user.membership || null
    }));

    return res.json({ success: true, users });
  } catch (err) {
    console.error('❌ GET /api/users error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
//   STATIC DATA FOR MORE TAB (Workshops, Blogs, Vedic Programs)
// ═══════════════════════════════════════════════════════════════════════════════

app.get('/api/workshops', (req, res) => {
  return res.json({
    success: true,
    workshops: [
      {
        id: "1",
        title: "Mindfulness Basics\nWorkshop",
        description: "Learn the core techniques of mindfulness to reduce daily stress and improve focus. This interactive session covers breathing exercises and mental framing.",
        imagePath: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop",
        tag: "MEDITATION",
        date: "Jul 15, 2026",
        time: "10:00 AM",
        duration: "2 Hours",
        instructorName: "Dr. Ananya Sharma",
        price: "₹500",
        requirements: ["Comfortable clothing", "Notebook and pen"]
      },
      {
        id: "2",
        title: "Advanced Yoga\nFlow",
        description: "Deepen your practice with advanced asanas focusing on core strength and flexibility. Suitable for intermediate practitioners.",
        imagePath: "https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?q=80&w=600&auto=format&fit=crop",
        tag: "YOGA",
        date: "Jul 20, 2026",
        time: "06:30 AM",
        duration: "90 Mins",
        instructorName: "Yogi Rahul",
        price: "₹800",
        requirements: ["Yoga mat", "Water bottle"]
      }
    ]
  });
});

app.get('/api/blogs', (req, res) => {
  return res.json({
    success: true,
    blogs: [
      {
        id: "1",
        title: "5 Simple Ayurvedic Habits for Morning Energy",
        category: "AYURVEDA",
        date: "Jun 10, 2026",
        readTime: "5 min read",
        author: "Vaidya Meera",
        imagePath: "https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?q=80&w=600&auto=format&fit=crop",
        content: "Starting your day with Ayurvedic practices can dramatically improve your energy levels. Here are five simple habits: 1. Wake up before sunrise (Brahma Muhurta). 2. Scrape your tongue to remove toxins. 3. Drink warm water with lemon. 4. Practice oil pulling (Gandusha). 5. Do light morning stretches (Surya Namaskar)."
      },
      {
        id: "2",
        title: "Understanding Your Dosha: Vata, Pitta, Kapha",
        category: "WELLNESS",
        date: "Jun 05, 2026",
        readTime: "8 min read",
        author: "Vaidya Meera",
        imagePath: "https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=600&auto=format&fit=crop",
        content: "Ayurveda categorizes mind-body types into three doshas: Vata (Air/Space), Pitta (Fire/Water), and Kapha (Earth/Water). Understanding your primary dosha helps tailor your diet, exercise, and lifestyle choices for optimal health and balance."
      }
    ]
  });
});

app.get('/api/vedic-programs', (req, res) => {
  return res.json({
    success: true,
    programs: [
      {
        id: "1",
        title: "Sattva Retreat\nProgram",
        subtitle: "Holistic Detox & Rejuvenation",
        duration: "7 Days",
        price: "₹15,000",
        originalPrice: "₹22,000",
        description: "A comprehensive 7-day program designed to cleanse your body of toxins and rejuvenate your mind through traditional Ayurvedic therapies, tailored diet, and guided meditation.",
        benefits: ["Improved digestion", "Deep relaxation", "Enhanced mental clarity", "Immune system boost"],
        whatsIncluded: ["Daily Ayurvedic consultations", "Customized meal plan", "Daily yoga sessions", "3 full-body Abhyanga massages"],
        imagePath: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop",
        tags: ["DETOX", "RELAXATION"]
      },
      {
        id: "2",
        title: "Ojas Immunity\nBooster",
        subtitle: "Strengthen Your Vitality",
        duration: "14 Days",
        price: "₹25,000",
        originalPrice: "₹35,000",
        description: "Focusing on building 'Ojas'—the essence of immunity and vitality in Ayurveda. This program includes specialized herbal treatments and lifestyle modifications.",
        benefits: ["Stronger immune response", "Increased energy levels", "Better sleep quality", "Stress reduction"],
        whatsIncluded: ["Herbal supplements", "2 Shirodhara sessions", "Dietary guidelines", "Weekly check-ins"],
        imagePath: "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?q=80&w=600&auto=format&fit=crop",
        tags: ["IMMUNITY", "VITALITY"]
      }
    ]
  });
});

// ─── Start Server ─────────────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Tapovana Backend running on http://0.0.0.0:${PORT}`);
});
