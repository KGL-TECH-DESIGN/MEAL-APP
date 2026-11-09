const express = require('express');
const cors = require('cors');
const pool = require('./db');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));


const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Backend server running on port ${PORT}`);
});

// Helper function to check 9:30 AM cutoff
function isCutoffPassed() {
    const now = new Date();
    const cutoff = new Date();
    cutoff.setHours(9, 30, 0, 0);
    return now >= cutoff;
}

// GET /api/departments - Fetch departments from the departments table
app.get('/api/departments', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT department_name FROM departments ORDER BY department_name ASC');
        const departments = rows.map(row => row.department_name);
        res.json(departments);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch departments.' });
    }
});

// 1. LOGIN API
app.post('/api/login', async (req, res) => {
    try {
        const { companyId, department, role } = req.body;
        const cleanId = (companyId || '').trim().toUpperCase();

        if (role === 'kitchen') {
            const [rows] = await pool.query(
                'SELECT * FROM kitchen_staff WHERE company_id = ?', 
                [cleanId]
            );
            if (rows.length === 0) {
                return res.status(401).json({ error: 'Kitchen staff ID not found.' });
            }
            return res.json({ success: true, user: rows[0] });
        }

        // Supervisor login
        const [rows] = await pool.query(
            'SELECT * FROM supervisors WHERE company_id = ?', 
            [cleanId]
        );
        if (rows.length === 0) {
            return res.status(401).json({ error: 'Supervisor ID not found.' });
        }

        const supervisor = rows[0];
        if (supervisor.department !== department) {
            return res.status(400).json({ 
                error: `This ID is registered under ${supervisor.department}, not ${department}.` 
            });
        }

        res.json({ success: true, user: supervisor });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error during login.' });
    }
});

// 2. GET MENU API
app.get('/api/menu', async (req, res) => {
    try {
        const { shift } = req.query;
        if (!shift) return res.status(400).json({ error: 'Shift is required.' });

        const [rows] = await pool.query(
            'SELECT * FROM menu_items WHERE shift = ?', 
            [shift.toUpperCase()]
        );
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch menu.' });
    }
});

// 3. SUBMIT ORDER API (Server-side 9:30 AM Cutoff Enforcement)
app.post('/api/orders', async (req, res) => {
    const connection = await pool.getConnection();
    try {
        if (isCutoffPassed()) {
            return res.status(400).json({ 
                error: 'Ordering closed. The 9:30 AM cutoff has passed.' 
            });
        }

        const { date, shift, department, supervisorId, items } = req.body;
        
        if (!items || items.length === 0) {
            return res.status(400).json({ error: 'No items in order.' });
        }

        await connection.beginTransaction();

        const totalMeals = items.reduce((sum, item) => sum + item.quantity, 0);

        const [orderResult] = await connection.query(
            `INSERT INTO orders (order_date, shift, department, supervisor_id, total_meals, status) 
             VALUES (?, ?, ?, ?, ?, 'Submitted')`,
            [date, shift, department, supervisorId, totalMeals]
        );

        const orderId = orderResult.insertId;

        for (const item of items) {
            await connection.query(
                `INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES (?, ?, ?)`,
                [orderId, item.menuItemId, item.quantity]
            );
        }

        await connection.commit();
        res.json({ success: true, message: 'Order submitted successfully', orderId, totalMeals });

    } catch (err) {
        await connection.rollback();
        console.error(err);
        res.status(500).json({ error: 'Failed to submit order.' });
    } finally {
        connection.release();
    }
});

// 4. GET ORDERS / HISTORY API
app.get('/api/orders', async (req, res) => {
    try {
        const { date, shift, department } = req.query;
        
        let sql = `
            SELECT id, order_date as date, shift, department, 
                   supervisor_id as supervisorId, total_meals as total, status 
            FROM orders WHERE 1=1
        `;
        let params = [];

        if (date) {
            sql += ` AND order_date = ?`;
            params.push(date);
        }
        if (shift && shift !== 'ALL') {
            sql += ` AND shift = ?`;
            params.push(shift);
        }
        if (department) {
            sql += ` AND department = ?`;
            params.push(department);
        }

        sql += ` ORDER BY created_at DESC`;

        const [orders] = await pool.query(sql, params);

        for (let order of orders) {
            const [items] = await pool.query(
                `SELECT mi.id as menuItemId, mi.name as menuItemName, oi.quantity 
                 FROM order_items oi 
                 JOIN menu_items mi ON oi.menu_item_id = mi.id 
                 WHERE oi.order_id = ?`,
                [order.id]
            );
            order.items = items;
        }

        res.json(orders);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch orders.' });
    }
});

// Root route
app.get('/', (req, res) => {
    res.send('Employee Meal Ordering System Backend is running successfully!');
});

app.listen(PORT, () => {
    console.log(`Backend server running on port ${PORT}`);
});
