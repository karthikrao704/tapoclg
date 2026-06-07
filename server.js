const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// PostgreSQL Neon DB Pool Connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Required for Neon SSL connection
  }
});

// Initialize Database Table
async function initDatabase() {
  const createTableQuery = `
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
  try {
    const client = await pool.connect();
    console.log('🔌 Connected to Neon PostgreSQL database.');
    await client.query(createTableQuery);
    console.log('✅ Table "service_bookings" is ready.');
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

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server listening on http://0.0.0.0:${PORT}`);
});
