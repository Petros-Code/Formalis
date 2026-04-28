const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 3000;

const dbConfig = {
  host: process.env.MYSQL_HOST || 'db',
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
};

app.get('/api/health', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    await connection.ping();
    await connection.end();
    res.json({ status: 'ok', database: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', database: 'unreachable', message: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Formalis API running on port ${PORT}`);
});
