-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 30, 2025 at 02:07 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `product_sales`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_top_product` ()   BEGIN
  SELECT p.product_name,
         p.product_code,
         IFNULL(SUM(s.quantity),0) AS total_sold
  FROM product p
  LEFT JOIN sales s ON s.product_code = p.product_code
  GROUP BY p.product_code, p.product_name
  ORDER BY total_sold DESC
  LIMIT 5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_sale` (IN `in_sales_reference` VARCHAR(100), IN `in_sales_date` DATETIME, IN `in_product_code` VARCHAR(50), IN `in_quantity` INT, IN `in_price` DECIMAL(12,2))   BEGIN
  DECLARE current_stock INT DEFAULT 0;
  DECLARE v_subtotal DECIMAL(14,2);

  START TRANSACTION;
  -- Ambil stok dan lock row
  SELECT stock INTO current_stock
  FROM product
  WHERE product_code = in_product_code
  FOR UPDATE;

  IF current_stock IS NULL THEN
    -- produk tidak ditemukan
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
  ELSEIF current_stock < in_quantity THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
  ELSE
    SET v_subtotal = in_quantity * in_price;

    INSERT INTO sales (sales_reference, sales_date, product_code, quantity, price, subtotal)
    VALUES (in_sales_reference, in_sales_date, in_product_code, in_quantity, in_price, v_subtotal);

    UPDATE product
    SET stock = stock - in_quantity
    WHERE product_code = in_product_code;

    COMMIT;
  END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `id_product` int NOT NULL,
  `product_code` varchar(50) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `stock` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id_product`, `product_code`, `product_name`, `price`, `stock`, `created_at`, `updated_at`) VALUES
(1, 'P-001', 'Kopi Arabika', 45000.00, 90, '2025-10-30 15:32:02', '2025-10-30 16:34:56'),
(2, 'P-002', 'Teh Hijau', 25000.00, 120, '2025-10-30 15:32:02', '2025-10-30 15:32:02'),
(3, 'P-003', 'Biskuit Cokelat', 12000.00, 185, '2025-10-30 15:32:02', '2025-10-30 16:09:51'),
(4, 'P-004', 'Susu UHT 1L', 15000.00, 80, '2025-10-30 15:32:02', '2025-10-30 15:32:02'),
(5, 'P-005', 'Minyak Goreng 2L', 28000.00, 60, '2025-10-30 15:32:02', '2025-10-30 15:32:02'),
(6, 'P-006', 'Gula Pasir 1kg', 12000.00, 150, '2025-10-30 15:32:02', '2025-10-30 15:32:02'),
(7, 'P-007', 'Beras Super 5kg', 85000.00, 25, '2025-10-30 15:32:02', '2025-10-30 16:21:45'),
(8, 'P-008', 'Roti Tawar', 8000.00, 180, '2025-10-30 15:32:02', '2025-10-30 15:32:02'),
(9, 'P-009', 'Sosis Ayam 250g', 18000.00, 90, '2025-10-30 15:32:02', '2025-10-30 15:32:02'),
(10, 'P-010', 'Sikat Gigi', 9000.00, 130, '2025-10-30 15:32:02', '2025-10-30 15:32:02');

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

CREATE TABLE `sales` (
  `id_sales` int NOT NULL,
  `sales_reference` varchar(100) NOT NULL,
  `sales_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `product_code` varchar(50) NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `subtotal` decimal(14,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`id_sales`, `sales_reference`, `sales_date`, `product_code`, `quantity`, `price`, `subtotal`, `created_at`) VALUES
(2, 'SR-0002', '2025-02-03 14:20:00', 'P-002', 20, 25000.00, 500000.00, '2025-10-30 15:32:03'),
(3, 'SR-0003', '2025-02-20 09:10:00', 'P-003', 35, 12000.00, 420000.00, '2025-10-30 15:32:03'),
(4, 'SR-0004', '2025-03-05 11:45:00', 'P-004', 18, 15000.00, 270000.00, '2025-10-30 15:32:03'),
(5, 'SR-0005', '2025-03-18 16:05:00', 'P-005', 10, 28000.00, 280000.00, '2025-10-30 15:32:03'),
(6, 'SR-0006', '2025-04-02 08:30:00', 'P-006', 25, 12000.00, 300000.00, '2025-10-30 15:32:03'),
(7, 'SR-0007', '2025-04-15 13:00:00', 'P-007', 8, 85000.00, 680000.00, '2025-10-30 15:32:03'),
(8, 'SR-0008', '2025-05-01 07:50:00', 'P-008', 30, 8000.00, 240000.00, '2025-10-30 15:32:03'),
(9, 'SR-0009', '2025-05-12 15:15:00', 'P-009', 14, 18000.00, 252000.00, '2025-10-30 15:32:03'),
(10, 'SR-0010', '2025-05-25 12:00:00', 'P-010', 40, 9000.00, 360000.00, '2025-10-30 15:32:03'),
(11, 'SR-1761814125279', '2025-10-30 07:00:00', 'P-007', 1, 85000.00, 85000.00, '2025-10-30 15:48:45'),
(12, 'SR-1761814161964', '2025-10-30 07:00:00', 'P-007', 1, 85000.00, 85000.00, '2025-10-30 15:49:22'),
(13, 'SR-1761814174230', '2025-10-30 07:00:00', 'P-007', 3, 85000.00, 255000.00, '2025-10-30 15:49:34'),
(14, 'SR-1761814181152', '2025-10-30 07:00:00', 'P-003', 5, 12000.00, 60000.00, '2025-10-30 15:49:41'),
(15, 'SR-1761814189852', '2025-10-30 07:00:00', 'P-003', 5, 12000.00, 60000.00, '2025-10-30 15:49:49'),
(16, 'SR-1761815391076', '2025-10-30 07:00:00', 'P-003', 5, 12000.00, 60000.00, '2025-10-30 16:09:51'),
(17, 'SR-1761815888919', '2025-10-30 16:18:08', 'P-007', 5, 85000.00, 425000.00, '2025-10-30 16:18:08'),
(18, 'SR-1761816105028', '2025-10-30 16:21:45', 'P-007', 5, 85000.00, 425000.00, '2025-10-30 16:21:45'),
(19, 'SR-1001', '2025-10-30 14:30:00', 'P-001', 10, 50000.00, 500000.00, '2025-10-30 16:34:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id_product`),
  ADD UNIQUE KEY `product_code` (`product_code`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`id_sales`),
  ADD UNIQUE KEY `sales_reference` (`sales_reference`),
  ADD KEY `idx_product_code` (`product_code`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `sales`
--
ALTER TABLE `sales`
  MODIFY `id_sales` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `sales`
--
ALTER TABLE `sales`
  ADD CONSTRAINT `fk_sales_product_code` FOREIGN KEY (`product_code`) REFERENCES `product` (`product_code`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
