const express = require("express");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { SECRET } = require("../middleware/auth");

const router = express.Router();

const demoUser = {
    username: "admin",
    // hash password 'password'
    passwordHash: bcrypt.hashSync("password", 10),
};

router.post("/login", async (req, res) => {
    const { username, password } = req.body;
    if (username !== demoUser.username) {
        return res.status(401).json({ message: "Invalid credentials" });
    }
    const ok = await bcrypt.compare(password, demoUser.passwordHash);
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    const token = jwt.sign({ username: demoUser.username }, SECRET, {
        expiresIn: "8h",
    });
    res.json({ token });
});

module.exports = router;
