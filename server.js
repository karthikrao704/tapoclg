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

// ΓöÇΓöÇΓöÇ Middleware ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));
app.use('/uploads', express.static(uploadsDir));

// ΓöÇΓöÇΓöÇ PostgreSQL Pool ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

// ΓöÇΓöÇΓöÇ Nodemailer transporter ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
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
  console.log('≡ƒôº Gmail email transporter configured for:', process.env.EMAIL_USER);
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
  console.log('≡ƒôº Brevo email transporter configured for:', process.env.BREVO_EMAIL);
} else {
  console.log('ΓÜá∩╕Å  No email credentials set ΓÇö OTPs will be logged to console only.');
}

// ΓöÇΓöÇΓöÇ Send OTP helper ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
async function sendOtpEmail(email, otp, purpose) {
  const subject = purpose === 'signup'
    ? 'Tapovana ΓÇö Verify your email'
    : (purpose === 'reset_password' ? 'Tapovana ΓÇö Reset your password' : 'Tapovana ΓÇö Login OTP');
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
            console.log(`≡ƒôº OTP sent via Resend API to ${email}`);
            resolve();
          } else {
            console.error('Γ¥î Resend API Error Response:', responseBody);
            reject(new Error(`Resend API returned status ${res.statusCode}`));
          }
        });
      });

      req.on('error', (err) => {
        console.error('Γ¥î Resend HTTP request error:', err);
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
    console.log(`≡ƒôº OTP sent to ${email}`);
  } else {
    // Fallback: log to console (visible in Render logs)
    console.log(`\n≡ƒöÉ ===== OTP FOR ${email} =====`);
    console.log(`   OTP: ${otp}`);
    console.log(`   Purpose: ${purpose}`);
    console.log(`================================\n`);
  }
}

// ΓöÇΓöÇΓöÇ Generate 6-digit OTP ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ΓöÇΓöÇΓöÇ JWT helper ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: '30d' });
}

// ΓöÇΓöÇΓöÇ Database Init ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
async function initDatabase() {
  const client = await pool.connect();
  try {
    console.log('≡ƒöî Connected to Neon PostgreSQL database.');

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

    console.log('Γ£à All tables are ready.');
  } catch (err) {
    console.error('Γ¥î Database initialization failed:', err);
    process.exit(1);
  } finally {
    client.release();
  }
}

initDatabase();

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   HEALTH CHECKS
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Tapovana Backend is running.' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Tapovana Backend is healthy.' });
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö SIGNUP: SEND OTP
//   Body: { email, password } OR { email, provider: "google" }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

app.post('/api/auth/signup/send-otp', async (req, res) => {
  const { email, password, provider } = req.body;

  if (!email) return res.status(400).json({ success: false, message: 'Email is required.' });

  try {
    // Check if user already exists
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);

    if (provider === 'google') {
      // Google signup ΓÇö no OTP needed, just check existence
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
    console.error('Γ¥î send-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö SIGNUP: VERIFY OTP
//   Body: { email, otp }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î verify-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö FORGOT PASSWORD: SEND OTP
//   Body: { email }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
app.post('/api/auth/signup/forgot-password/send-otp', async (req, res) => {
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

    return res.json({ success: true, message: 'Reset OTP sent to your email.' });
  } catch (err) {
    console.error('Γ¥î forgot-password/send-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö FORGOT PASSWORD: VERIFY OTP
//   Body: { email, otp }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
app.post('/api/auth/signup/forgot-password/verify-otp', async (req, res) => {
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
    return res.json({ success: true, message: 'OTP verified.' });
  } catch (err) {
    console.error('Γ¥î forgot-password/verify-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö FORGOT PASSWORD: RESET PASSWORD
//   Body: { email, new_password }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
app.post('/api/auth/signup/forgot-password/reset', async (req, res) => {
  const { email, new_password } = req.body;
  if (!email || !new_password) return res.status(400).json({ success: false, message: 'Email and new password are required.' });

  try {
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const passwordHash = await bcrypt.hash(new_password, 10);
    await pool.query('UPDATE users SET password_hash = $1 WHERE email = $2', [passwordHash, email]);

    return res.json({ success: true, message: 'Password reset successful.' });
  } catch (err) {
    console.error('Γ¥î forgot-password/reset error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö SIGNUP: COMPLETE
//   Email body: { email, password, name, gender, city }
//   Google body: { email, uid, provider: "google", name, gender, city }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î signup/complete error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö LOGIN
//   Email body: { email, password }
//   Google body: { email, uid, provider: "google" }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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

    // Email login ΓÇö verify password
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
    console.error('Γ¥î login error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö LOGIN: VERIFY OTP (2FA)
//   Body: { email, otp }
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î login/verify-otp error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   AUTH ΓÇö TWO-STEP STATUS
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

app.get('/api/auth/two-step/status/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query('SELECT two_step_verification FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found.' });
    return res.json({ success: true, two_step_verification: result.rows[0].two_step_verification });
  } catch (err) {
    console.error('Γ¥î two-step/status error:', err);
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
    console.error('Γ¥î two-step/toggle error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   USER DETAILS ΓÇö GET
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î GET /api/details error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   USER DETAILS ΓÇö PATCH (update personal info)
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î PATCH /api/details error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   USER DETAILS ΓÇö PATCH profile photo
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î PATCH /profile-photo error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   USER DETAILS ΓÇö DELETE profile photo
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î DELETE /profile-photo error:', err);
    return res.status(500).json({ success: false, message: 'Server error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   BOOKINGS ΓÇö POST
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

app.post('/api/bookings', async (req, res) => {
  const { userName, profilePic, serviceName, bookingDate, bookingTime, therapistName, note, totalAmount, passDetails } = req.body;

  if (!userName || !serviceName || !bookingDate || !bookingTime || !therapistName || !totalAmount) {
    return res.status(400).json({ error: 'Missing required fields.' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO service_bookings (user_name, profile_pic, service_name, booking_date, booking_time, therapist_name, note, total_amount, pass_details)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING id, created_at`,
      [userName, profilePic || null, serviceName, bookingDate, bookingTime, therapistName, note || null, totalAmount, passDetails || null]
    );

    return res.status(201).json({
      success: true,
      message: 'Booking saved.',
      bookingId: result.rows[0].id,
      createdAt: result.rows[0].created_at,
    });
  } catch (err) {
    console.error('Γ¥î POST /api/bookings error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   BOOKINGS ΓÇö GET ALL (optional ?userName= filter)
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

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
    console.error('Γ¥î GET /api/bookings error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
//   BOOKINGS ΓÇö GET SINGLE
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

app.get('/api/bookings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM service_bookings WHERE id = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: `Booking ${id} not found.` });
    return res.json({ success: true, booking: result.rows[0] });
  } catch (err) {
    console.error('Γ¥î GET /api/bookings/:id error:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

// ΓöÇΓöÇΓöÇ Start Server ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
app.listen(PORT, '0.0.0.0', () => {
  console.log(`≡ƒÜÇ Tapovana Backend running on http://0.0.0.0:${PORT}`);
});
