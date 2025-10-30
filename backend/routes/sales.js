const express = require("express");
const pool = require("../db");
const { authenticateToken } = require("../middleware/auth");

const router = express.Router();

router.post("/", authenticateToken, async (req, res) => {
    const { sales_reference, sales_date, product_code, quantity, price } =
        req.body;
    function toMysqlDatetime(d) {
        const date = d instanceof Date ? d : new Date(d);
        if (isNaN(date)) return null;
        const pad = (n) => String(n).padStart(2, "0");
        const Y = date.getFullYear();
        const M = pad(date.getMonth() + 1);
        const D = pad(date.getDate());
        const h = pad(date.getHours());
        const m = pad(date.getMinutes());
        const s = pad(date.getSeconds());
        return `${Y}-${M}-${D} ${h}:${m}:${s}`;
    }
    const salesDateParam =
        toMysqlDatetime(sales_date) || toMysqlDatetime(new Date());

    if (!product_code)
        return res.status(400).json({ message: "Missing product_code" });
    const qty = parseInt(quantity, 10);
    if (isNaN(qty) || qty <= 0)
        return res.status(400).json({ message: "Invalid quantity" });
    const pr = parseFloat(price);
    if (isNaN(pr) || pr < 0)
        return res.status(400).json({ message: "Invalid price" });

    try {
        const conn = await pool.getConnection();
        try {
            await conn.query("CALL sp_create_sale(?, ?, ?, ?, ?)", [
                sales_reference,
                salesDateParam,
                product_code,
                qty,
                pr,
            ]);
            res.status(201).json({ message: "Sale created" });
        } finally {
            conn.release();
        }
    } catch (err) {
        // Log full error server-side for debugging
        console.error("Error creating sale", {
            body: req.body,
            salesDateParam,
            err,
        });

        const msg = (err && (err.sqlMessage || err.message)) || "Unknown error";
        res.status(400).json({ message: msg });
    }
});

/* List sales (paginated) */
router.get("/", authenticateToken, async (req, res) => {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const pageSize = Math.max(parseInt(req.query.pageSize) || 20, 1);
    const offset = (page - 1) * pageSize;
    try {
        const [rows] = await pool.query(
            "SELECT * FROM sales ORDER BY sales_date DESC LIMIT ? OFFSET ?",
            [pageSize, offset]
        );
        const [[{ total }]] = await pool.query(
            "SELECT COUNT(*) as total FROM sales"
        );
        res.json({ data: rows, pagination: { page, pageSize, total } });
    } catch (err) {
        console.error("Error listing sales", err);

        const msg =
            (err && (err.sqlMessage || err.message)) || "Failed to list sales";
        res.status(500).json({ message: msg });
    }
});

router.get("/top-products", authenticateToken, async (req, res) => {
    try {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.query("CALL get_top_product()");
            const result = rows[0] ? rows[0] : rows;
            res.json(result);
        } finally {
            conn.release();
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

/* Get sale by id */
router.get("/:id", authenticateToken, async (req, res) => {
    const id = req.params.id;
    try {
        const [rows] = await pool.query(
            "SELECT * FROM sales WHERE id_sales = ?",
            [id]
        );
        if (!rows || rows.length === 0)
            return res.status(404).json({ message: "Not found" });
        res.json(rows[0]);
    } catch (err) {
        console.error("Error getting sale", err);
        const msg =
            (err && (err.sqlMessage || err.message)) || "Failed to get sale";
        res.status(500).json({ message: msg });
    }
});

router.put("/:id", authenticateToken, async (req, res) => {
    const id = req.params.id;
    const { quantity, price, sales_reference, sales_date } = req.body;
    const qty = typeof quantity !== "undefined" ? parseInt(quantity, 10) : null;
    const pr = typeof price !== "undefined" ? parseFloat(price) : null;
    try {
        // Basic validation
        if (qty !== null && (isNaN(qty) || qty <= 0))
            return res.status(400).json({ message: "Invalid quantity" });
        if (pr !== null && (isNaN(pr) || pr < 0))
            return res.status(400).json({ message: "Invalid price" });

        // Build update dynamically
        const sets = [];
        const params = [];
        if (sales_reference !== undefined) {
            sets.push("sales_reference = ?");
            params.push(sales_reference);
        }
        if (sales_date !== undefined) {
            sets.push("sales_date = ?");
            params.push(sales_date);
        }
        if (qty !== null) {
            sets.push("quantity = ?");
            params.push(qty);
        }
        if (pr !== null) {
            sets.push("price = ?");
            params.push(pr);
        }
        if (sets.length === 0)
            return res.status(400).json({ message: "No fields to update" });
        params.push(id);
        const sql = `UPDATE sales SET ${sets.join(", ")} WHERE id_sales = ?`;
        const [result] = await pool.query(sql, params);
        if (result.affectedRows === 0)
            return res.status(404).json({ message: "Not found" });
        res.json({ message: "Updated" });
    } catch (err) {
        console.error("Error updating sale", { id, body: req.body, err });
        const msg =
            (err && (err.sqlMessage || err.message)) || "Failed to update sale";
        res.status(500).json({ message: msg });
    }
});

router.delete("/:id", authenticateToken, async (req, res) => {
    const id = req.params.id;
    try {
        const [result] = await pool.query(
            "DELETE FROM sales WHERE id_sales = ?",
            [id]
        );
        if (result.affectedRows === 0)
            return res.status(404).json({ message: "Not found" });
        res.json({ message: "Deleted" });
    } catch (err) {
        console.error("Error deleting sale", { id, err });
        const msg =
            (err && (err.sqlMessage || err.message)) || "Failed to delete sale";
        res.status(500).json({ message: msg });
    }
});

module.exports = router;
