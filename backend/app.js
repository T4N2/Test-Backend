const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const productsRouter = require("./routes/products");
const salesRouter = require("./routes/sales");
const authRouter = require("./routes/auth");

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.use("/api/auth", authRouter);
app.use("/api/products", productsRouter);
app.use("/api/sales", salesRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("Server running on port", PORT));
