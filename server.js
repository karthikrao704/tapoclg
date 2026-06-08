const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// PostgreSQL Neon DB Pool Connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Required for Neon SSL connection
  }
});

// Initialize Database Table
async function initDatabase() {
  const createBookingsTableQuery = `
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
  `;

  const createUsersTableQuery = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      password VARCHAR(255),
      name VARCHAR(255) NOT NULL,
      gender VARCHAR(50),
      city VARCHAR(255),
      address TEXT,
      phone VARCHAR(50),
      dob VARCHAR(50),
      health_concerns TEXT,
      preferred_therapies TEXT,
      allergies TEXT,
      membership VARCHAR(100) DEFAULT 'Free',
      two_step_verification BOOLEAN DEFAULT FALSE,
      profile_photo_url TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createOtpsTableQuery = `
    CREATE TABLE IF NOT EXISTS user_otps (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) NOT NULL,
      otp VARCHAR(10) NOT NULL,
      expires_at TIMESTAMP NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const seedDefaultUserQuery = `
    INSERT INTO users (email, password, name, city, gender, phone, membership)
    VALUES ('test@example.com', 'password', 'Test User', 'San Francisco, USA', 'Male', '1234567890', 'Premium')
    ON CONFLICT (email) DO NOTHING;
  `;

  try {
    const client = await pool.connect();
    console.log('🔌 Connected to Neon PostgreSQL database.');
    
    await client.query(createBookingsTableQuery);
    console.log('✅ Table "service_bookings" is ready.');

    await client.query(createUsersTableQuery);
    console.log('✅ Table "users" is ready.');

    await client.query(createOtpsTableQuery);
    console.log('✅ Table "user_otps" is ready.');

    await client.query(seedDefaultUserQuery);
    console.log('✅ Default user seeded successfully.');

    client.release();
  } catch (err) {
    console.error('❌ Database connection or initialization failed:', err);
    process.exit(1);
  }
}

initDatabase();

// Health Check
app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Tapovana Wellness Backend is running.' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Tapovana Wellness Backend is healthy.' });
});


// Booking Endpoint
app.post('/api/bookings', async (req, res) => {
  const {
    userName,
    profilePic,
    serviceName,
    bookingDate,
    bookingTime,
    therapistName,
    note,
    totalAmount,
    passDetails
  } = req.body;

  // Basic Validation
  if (!userName || !serviceName || !bookingDate || !bookingTime || !therapistName || !totalAmount) {
    return res.status(400).json({
      error: 'Missing required fields. Required: userName, serviceName, bookingDate, bookingTime, therapistName, totalAmount'
    });
  }

  const insertQuery = `
    INSERT INTO service_bookings (
      user_name,
      profile_pic,
      service_name,
      booking_date,
      booking_time,
      therapist_name,
      note,
      total_amount,
      pass_details
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    RETURNING id, created_at;
  `;

  const values = [
    userName,
    profilePic || null,
    serviceName,
    bookingDate,
    bookingTime,
    therapistName,
    note || null,
    totalAmount,
    passDetails || null
  ];

  try {
    const result = await pool.query(insertQuery, values);
    const newBooking = result.rows[0];
    
    console.log(`🎉 Booking saved successfully: ID ${newBooking.id} for ${userName} (${serviceName})`);
    
    return res.status(201).json({
      success: true,
      message: 'Booking successfully stored in PostgreSQL!',
      bookingId: newBooking.id,
      createdAt: newBooking.created_at
    });
  } catch (err) {
    console.error('❌ Failed to insert booking into database:', err);
    return res.status(500).json({
      error: 'Database error. Failed to save booking details.'
    });
  }
});

// Fetch all bookings (optionally filter by userName query parameter)
app.get('/api/bookings', async (req, res) => {
  const { userName } = req.query;
  try {
    let result;
    if (userName) {
      const query = `
        SELECT * FROM service_bookings 
        WHERE user_name = $1 
        ORDER BY id DESC;
      `;
      result = await pool.query(query, [userName]);
    } else {
      const query = `
        SELECT * FROM service_bookings 
        ORDER BY id DESC;
      `;
      result = await pool.query(query);
    }
    
    return res.json({
      success: true,
      count: result.rows.length,
      bookings: result.rows
    });
  } catch (err) {
    console.error('❌ Failed to fetch bookings from database:', err);
    return res.status(500).json({
      error: 'Database error. Failed to retrieve booking details.'
    });
  }
});

// Fetch a single booking by ID
app.get('/api/bookings/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const query = 'SELECT * FROM service_bookings WHERE id = $1;';
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: `Booking with ID ${id} not found.`
      });
    }
    
    return res.json({
      success: true,
      booking: result.rows[0]
    });
  } catch (err) {
    console.error(`❌ Failed to fetch booking with ID ${id}:`, err);
    return res.status(500).json({
      error: 'Database error. Failed to retrieve booking details.'
    });
  }
});


// Configure Multer Storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, 'profile-' + uniqueSuffix + ext);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: function (req, file, cb) {
    const ext = path.extname(file.originalname).toLowerCase();
    if (ext !== '.jpg' && ext !== '.jpeg' && ext !== '.png') {
      return cb(new Error('Only .jpg, .jpeg and .png images are allowed.'));
    }
    cb(null, true);
  }
});

// ─── AUTHENTICATION ENDPOINTS ────────────────────────────────────────────────

// 1. SIGNUP: Send OTP
app.post('/api/auth/signup/send-otp', async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ success: false, message: 'Email is required.' });
  }

  try {
    // Check if user already exists
    const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Email already registered.' });
    }

    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins expiration

    // Save/Overwrite OTP
    await pool.query('DELETE FROM user_otps WHERE email = $1', [email]);
    await pool.query(
      'INSERT INTO user_otps (email, otp, expires_at) VALUES ($1, $2, $3)',
      [email, otp, expiresAt]
    );

    console.log(`\n========================================`);
    console.log(`[OTP] Signup verification code for ${email}: ${otp}`);
    console.log(`========================================\n`);

    return res.json({ success: true, message: 'OTP sent successfully.' });
  } catch (err) {
    console.error('❌ Error sending signup OTP:', err);
    return res.status(500).json({ success: false, message: 'Failed to send OTP.' });
  }
});

// 2. SIGNUP: Verify OTP
app.post('/api/auth/signup/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) {
    return res.status(400).json({ success: false, message: 'Email and OTP are required.' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM user_otps WHERE email = $1 AND otp = $2 AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1',
      [email, otp]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP.' });
    }

    // Delete the verified OTP
    await pool.query('DELETE FROM user_otps WHERE email = $1', [email]);

    return res.json({ success: true, message: 'OTP verified successfully.' });
  } catch (err) {
    console.error('❌ Error verifying OTP:', err);
    return res.status(500).json({ success: false, message: 'Failed to verify OTP.' });
  }
});

// 3. SIGNUP: Complete
app.post('/api/auth/signup/complete', async (req, res) => {
  const { email, password, name, gender, city } = req.body;
  if (!email || !name) {
    return res.status(400).json({ success: false, message: 'Email and Name are required.' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO users (email, password, name, gender, city)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (email) DO UPDATE 
       SET password = EXCLUDED.password, name = EXCLUDED.name, gender = EXCLUDED.gender, city = EXCLUDED.city
       RETURNING *`,
      [email, password || null, name, gender || null, city || null]
    );

    const newUser = result.rows[0];
    const mockToken = 'mock-jwt-token-' + newUser.id + '-' + Math.random().toString(36).substring(2);

    return res.json({
      success: true,
      token: mockToken,
      user: {
        id: newUser.id,
        email: newUser.email,
        name: newUser.name
      }
    });
  } catch (err) {
    console.error('❌ Error completing signup:', err);
    return res.status(500).json({ success: false, message: 'Failed to complete signup.' });
  }
});

// 4. LOGIN: Password check + 2FA detection
app.post('/api/auth/login', async (req, res) => {
  const { email, password, provider, uid } = req.body;
  if (!email) {
    return res.status(400).json({ success: false, message: 'Email is required.' });
  }

  try {
    let result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    let user;

    if (result.rows.length === 0) {
      if (provider === 'google') {
        // Google signup on-the-fly or login check
        const namePart = email.split('@')[0];
        const insertResult = await pool.query(
          'INSERT INTO users (email, name, city) VALUES ($1, $2, $3) RETURNING *',
          [email, namePart, '']
        );
        user = insertResult.rows[0];
      } else {
        return res.status(404).json({ success: false, message: 'User not found.' });
      }
    } else {
      user = result.rows[0];
    }

    // Verify Password if email login
    if (provider !== 'google' && password && user.password && user.password !== password) {
      return res.status(401).json({ success: false, message: 'Incorrect password.' });
    }

    // Check if 2FA (two-step verification) is enabled
    if (user.two_step_verification) {
      const otp = Math.floor(1000 + Math.random() * 9000).toString();
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

      await pool.query('DELETE FROM user_otps WHERE email = $1', [email]);
      await pool.query(
        'INSERT INTO user_otps (email, otp, expires_at) VALUES ($1, $2, $3)',
        [email, otp, expiresAt]
      );

      console.log(`\n========================================`);
      console.log(`[OTP] 2FA Login verification code for ${email}: ${otp}`);
      console.log(`========================================\n`);

      return res.json({
        success: true,
        requires_otp: true,
        email: email,
        password: password
      });
    }

    // Normal Login Success
    const mockToken = 'mock-jwt-token-' + user.id + '-' + Math.random().toString(36).substring(2);
    return res.json({
      success: true,
      requires_otp: false,
      token: mockToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  } catch (err) {
    console.error('❌ Error logging in:', err);
    return res.status(500).json({ success: false, message: 'Login failed.' });
  }
});

// 5. LOGIN: Verify 2FA OTP
app.post('/api/auth/login/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) {
    return res.status(400).json({ success: false, message: 'Email and OTP are required.' });
  }

  try {
    const otpResult = await pool.query(
      'SELECT * FROM user_otps WHERE email = $1 AND otp = $2 AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1',
      [email, otp]
    );

    if (otpResult.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP.' });
    }

    // Fetch user
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const user = userResult.rows[0];

    // Delete verified OTP
    await pool.query('DELETE FROM user_otps WHERE email = $1', [email]);

    const mockToken = 'mock-jwt-token-' + user.id + '-' + Math.random().toString(36).substring(2);
    return res.json({
      success: true,
      token: mockToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  } catch (err) {
    console.error('❌ Error verifying login OTP:', err);
    return res.status(500).json({ success: false, message: 'Failed to verify login OTP.' });
  }
});

// 6. 2FA Status
app.get('/api/auth/two-step/status/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query('SELECT two_step_verification FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }
    return res.json({
      success: true,
      two_step_verification: result.rows[0].two_step_verification
    });
  } catch (err) {
    console.error('❌ Error fetching 2FA status:', err);
    return res.status(500).json({ success: false, message: 'Database error.' });
  }
});

// 7. Toggle 2FA
app.post('/api/auth/two-step/toggle', async (req, res) => {
  const { id, enabled } = req.body;
  if (!id) {
    return res.status(400).json({ success: false, message: 'User ID is required.' });
  }

  try {
    const result = await pool.query(
      'UPDATE users SET two_step_verification = $1 WHERE id = $2 RETURNING *',
      [enabled === true, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.json({
      success: true,
      message: `2FA is now ${enabled ? 'enabled' : 'disabled'}.`
    });
  } catch (err) {
    console.error('❌ Error toggling 2FA:', err);
    return res.status(500).json({ success: false, message: 'Database error.' });
  }
});


// ─── USER DETAILS & PROFILE ENDPOINTS ────────────────────────────────────────

// 8. GET Profile Details
app.get('/api/details/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }
    return res.json({
      success: true,
      user: result.rows[0]
    });
  } catch (err) {
    console.error('❌ Error fetching user details:', err);
    return res.status(500).json({ success: false, message: 'Database error.' });
  }
});

// 9. PATCH Profile Details
app.patch('/api/details/:userId', async (req, res) => {
  const { userId } = req.params;
  const fields = req.body;

  if (Object.keys(fields).length === 0) {
    return res.status(400).json({ success: false, message: 'No fields to update.' });
  }

  // Build dynamic patch query
  const setClauses = [];
  const values = [];
  let index = 1;

  for (const [key, val] of Object.entries(fields)) {
    setClauses.push(`${key} = $${index}`);
    values.push(val);
    index++;
  }

  values.push(userId); // Last parameter is userId

  const query = `
    UPDATE users 
    SET ${setClauses.join(', ')} 
    WHERE id = $${index} 
    RETURNING *;
  `;

  try {
    const result = await pool.query(query, values);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }
    return res.json({
      success: true,
      message: 'Profile updated successfully.',
      user: result.rows[0]
    });
  } catch (err) {
    console.error('❌ Error updating profile details:', err);
    return res.status(500).json({ success: false, message: 'Database error.' });
  }
});

// 10. PATCH Profile Photo Upload
app.patch('/api/details/:userId/profile-photo', upload.single('profile_photo'), async (req, res) => {
  const { userId } = req.params;

  if (!req.file) {
    return res.status(400).json({ success: false, message: 'No profile photo uploaded.' });
  }

  // Construct URL to access the photo
  const hostUrl = `${req.protocol}://${req.get('host')}`;
  const profilePhotoUrl = `${hostUrl}/uploads/${req.file.filename}`;

  try {
    const result = await pool.query(
      'UPDATE users SET profile_photo_url = $1 WHERE id = $2 RETURNING *',
      [profilePhotoUrl, userId]
    );

    if (result.rows.length === 0) {
      // Remove local file if user not found
      fs.unlinkSync(req.file.path);
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.json({
      success: true,
      message: 'Profile photo uploaded successfully.',
      data: {
        profile_photo_url: profilePhotoUrl
      }
    });
  } catch (err) {
    console.error('❌ Error updating profile photo:', err);
    // Remove local file on database error
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    return res.status(500).json({ success: false, message: 'Database error.' });
  }
});

// Mock Services Data
const mockServices = [
  {
    id: "s1",
    service_id: "SRV-001",
    auth_user_id: "u1",
    name: "Deep Tissue Massage",
    category: "Body Care",
    subcategory: "Massages",
    description: "A therapeutic massage focusing on realigning deeper layers of muscles and connective tissue.",
    benefits: "Relieves chronic muscle tension\nReduces inflammation\nImproves blood circulation",
    tools: "Therapeutic massage oils\nHeated herbal compresses",
    base_price: "1500.00",
    duration_minutes: 60,
    required_certification: "Licensed Massage Therapist (LMT)",
    experience_level: "Intermediate",
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&auto=format&fit=crop",
    status: "Active",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    first_name: "Aarav",
    last_name: "Sharma",
    specialization: "Neuromuscular Therapy",
    avatar_url: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop",
    assigned_staff_details: [
      {
        id: "st1",
        first_name: "Aarav",
        last_name: "Sharma",
        email: "aarav.sharma@example.com",
        avatar_url: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop"
      }
    ]
  },
  {
    id: "s2",
    service_id: "SRV-002",
    auth_user_id: "u2",
    name: "Swedish Relaxing Massage",
    category: "Body Care",
    subcategory: "Massages",
    description: "A gentle full-body massage to promote relaxation, relieve muscle tension, and boost circulation.",
    benefits: "Reduces stress hormones\nIncreases physical relaxation\nImproves sleep quality",
    tools: "Organic lavender oil\nSoft ambient music",
    base_price: "1200.00",
    duration_minutes: 60,
    required_certification: "Licensed Massage Therapist (LMT)",
    experience_level: "Beginner",
    image_url: "https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?w=600&auto=format&fit=crop",
    status: "Active",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    first_name: "Sarah",
    last_name: "Miller",
    specialization: "Relaxation & Aromatherapy",
    avatar_url: "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop",
    assigned_staff_details: [
      {
        id: "st2",
        first_name: "Sarah",
        last_name: "Miller",
        email: "sarah.miller@example.com",
        avatar_url: "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop"
      }
    ]
  },
  {
    id: "s3",
    service_id: "SRV-003",
    auth_user_id: "u3",
    name: "Hydrating Facial",
    category: "Skin Care",
    subcategory: "Facials",
    description: "Deep cleansing facial treatment that hydrates the skin, leaving it refreshed and glowing.",
    benefits: "Deeply hydrates skin cells\nRestores natural skin radiance\nReduces dry patches",
    tools: "Steamer\nOrganic hydration masks",
    base_price: "999.00",
    duration_minutes: 45,
    required_certification: "Licensed Esthetician",
    experience_level: "Intermediate",
    image_url: "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=600&auto=format&fit=crop",
    status: "Active",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    first_name: "Priya",
    last_name: "Patel",
    specialization: "Dermatological Facials",
    avatar_url: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop",
    assigned_staff_details: [
      {
        id: "st3",
        first_name: "Priya",
        last_name: "Patel",
        email: "priya.patel@example.com",
        avatar_url: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop"
      }
    ]
  },
  {
    id: "s4",
    service_id: "SRV-004",
    auth_user_id: "u4",
    name: "Organic Hair Spa",
    category: "Hair Care",
    subcategory: "Hair Spa",
    description: "A nourishing spa treatment for hair that strengthens roots and restores moisture.",
    benefits: "Reduces hair breakage\nRestores hair shine & texture\nPrevents scalp dryness",
    tools: "Steam machine\nDeep conditioning creams",
    base_price: "1800.00",
    duration_minutes: 75,
    required_certification: "Certified Trichologist",
    experience_level: "Senior",
    image_url: "https://images.unsplash.com/photo-1562322140-8baeececf3df?w=600&auto=format&fit=crop",
    status: "Active",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    first_name: "Vikram",
    last_name: "Singh",
    specialization: "Hair & Scalp Health",
    avatar_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop",
    assigned_staff_details: [
      {
        id: "st4",
        first_name: "Vikram",
        last_name: "Singh",
        email: "vikram.singh@example.com",
        avatar_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop"
      }
    ]
  },
  {
    id: "s5",
    service_id: "SRV-005",
    auth_user_id: "u5",
    name: "Premium Spa Manicure",
    category: "Nail Care",
    subcategory: "Manicure",
    description: "Nourishing manicure treatment that cleanses, exfoliates, and shapes your nails beautifully.",
    benefits: "Softens hands and cuticles\nExfoliates dead skin cells\nEnhances nail growth",
    tools: "Nail buffers & shapers\nHand scrubs & moisturizers",
    base_price: "600.00",
    duration_minutes: 30,
    required_certification: "Certified Nail Technician",
    experience_level: "Beginner",
    image_url: "https://images.unsplash.com/photo-1604654894610-df63bc536371?w=600&auto=format&fit=crop",
    status: "Active",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    first_name: "Neha",
    last_name: "Kapoor",
    specialization: "Nail Artistry & Hand Spa",
    avatar_url: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop",
    assigned_staff_details: [
      {
        id: "st5",
        first_name: "Neha",
        last_name: "Kapoor",
        email: "neha.kapoor@example.com",
        avatar_url: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop"
      }
    ]
  },
  {
    id: "s6",
    service_id: "SRV-006",
    auth_user_id: "u6",
    name: "Bridal Glow Makeup",
    category: "Styling & Make over",
    subcategory: "Bridal Makeover",
    description: "Exquisite makeover designed for brides to make them look stunning on their special day.",
    benefits: "Long-lasting premium makeup\nCustom style consultation\nFlawless camera-ready finish",
    tools: "Premium makeup products\nAirbrush kit",
    base_price: "8500.00",
    duration_minutes: 120,
    required_certification: "Certified Professional Makeup Artist",
    experience_level: "Expert",
    image_url: "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600&auto=format&fit=crop",
    status: "Active",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    first_name: "Rohan",
    last_name: "Mehta",
    specialization: "High-Definition Bridal Makeovers",
    avatar_url: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop",
    assigned_staff_details: [
      {
        id: "st6",
        first_name: "Rohan",
        last_name: "Mehta",
        email: "rohan.mehta@example.com",
        avatar_url: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop"
      }
    ]
  }
];

// Mock Workshops Data
const mockWorkshops = [
  {
    title: "Vedic Meditation Fundamentals",
    category: "Meditation & Wellness",
    description: "Learn the core techniques of Vedic meditation to calm the mind and reduce daily anxiety.",
    time: "09:00 AM",
    duration: 60,
    date: new Date().toISOString(),
    image_url: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600&auto=format&fit=crop",
    video_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  },
  {
    title: "Yoga Alignment Workshop",
    category: "Hatha Yoga",
    description: "Focus on perfect alignment, postures, and breath control exercises for standard poses.",
    time: "07:30 AM",
    duration: 90,
    date: new Date().toISOString(),
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&auto=format&fit=crop",
    video_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }
];

// GET all services
app.get('/api/services', (req, res) => {
  return res.json({
    success: true,
    services: mockServices
  });
});

// GET single service by ID
app.get('/api/services/:id', (req, res) => {
  const { id } = req.params;
  const service = mockServices.find(s => s.id === id);
  if (!service) {
    return res.status(404).json({
      success: false,
      message: `Service with ID ${id} not found.`
    });
  }
  return res.json({
    success: true,
    service: service
  });
});

// GET all workshops
app.get('/api/workshops', (req, res) => {
  return res.json({
    success: true,
    workshops: mockWorkshops
  });
});


// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server listening on http://0.0.0.0:${PORT}`);
});
