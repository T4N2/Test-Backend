const express = require("express");
const pool = require("../db");
const { authenticateToken } = require("../middleware/auth");

const router = express.Router();

/* Create product */
router.post("/", authenticateToken, async (req, res) => {
    const { product_code, product_name, price, stock } = req.body;
    try {
        const [result] = await pool.query(
            "INSERT INTO product (product_code, product_name, price, stock) VALUES (?, ?, ?, ?)",
            [product_code, product_name, price, stock]
        );
        res.status(201).json({ id_product: result.insertId });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

/* Read product by id */
router.get("/:id", authenticateToken, async (req, res) => {
    const id = req.params.id;
    const [rows] = await pool.query(
        "SELECT * FROM product WHERE id_product = ?",
        [id]
    );
    if (rows.length === 0)
        return res.status(404).json({ message: "Not found" });
    res.json(rows[0]);
});

/* Update product */
router.put("/:id", authenticateToken, async (req, res) => {
    const id = req.params.id;
    const { product_name, price, stock } = req.body;
    try {
        await pool.query(
            "UPDATE product SET product_name = ?, price = ?, stock = ? WHERE id_product = ?",
            [product_name, price, stock, id]
        );
        res.json({ message: "Updated" });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

/* Delete product */
router.delete("/:id", authenticateToken, async (req, res) => {
    const id = req.params.id;
    try {
        await pool.query("DELETE FROM product WHERE id_product = ?", [id]);
        res.json({ message: "Deleted" });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

/* List products with filter name and pagination */
router.get("/", authenticateToken, async (req, res) => {
    const name = req.query.name || "";
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const pageSize = Math.max(parseInt(req.query.pageSize) || 10, 1);
    const offset = (page - 1) * pageSize;

    const search = "%" + name + "%";
    const [rows] = await pool.query(
        "SELECT * FROM product WHERE product_name LIKE ? OR product_code LIKE ? ORDER BY product_name LIMIT ? OFFSET ?",
        [search, search, pageSize, offset]
    );
    const [[{ total }]] = await pool.query(
        "SELECT COUNT(*) as total FROM product WHERE product_name LIKE ? OR product_code LIKE ?",
        [search, search]
    );
    res.json({
        data: rows,
        pagination: {
            page,
            pageSize,
            total,
        },
    });
});

module.exports = router;
