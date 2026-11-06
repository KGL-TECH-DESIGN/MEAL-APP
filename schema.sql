USE meal_ordering_db;

-- Drop existing tables to refresh structure if needed
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS kitchen_staff;
DROP TABLE IF EXISTS supervisors;
DROP TABLE IF EXISTS departments;

-- 1. Department Table
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id VARCHAR(50) UNIQUE NOT NULL,
    department_name VARCHAR(100) NOT NULL
);

-- 2. Supervisors Table
CREATE TABLE supervisors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL
);

-- 3. Kitchen Staff Table
CREATE TABLE kitchen_staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL
);

-- 4. Menu Items Table
CREATE TABLE menu_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    shift VARCHAR(20) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0.00
);

-- 5. Orders Table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    shift VARCHAR(20) NOT NULL,
    department VARCHAR(100) NOT NULL,
    supervisor_id VARCHAR(50) NOT NULL,
    total_meals INT NOT NULL,
    status VARCHAR(50) DEFAULT 'Submitted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Order Items Table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- ==========================================
-- SEEDING DEPARTMENTS & SUPERVISORS
-- ==========================================
INSERT INTO departments (department_id, department_name) VALUES 
('Dpt001', 'KGL Managerial Staff'),
('Dpt002', 'Administrative Staff'),
('Dpt003', 'Hard Rock/Exploration'),
('Dpt004', 'Rango(Workshop Builders)'),
('Dpt005', 'Plant Maintenance (Site-1)'),
('Dpt006', 'Hoppers (Site-1)'),
('Dpt007', 'Earth-Moving Equip. Mechanics'),
('Dpt008', 'Auto Mechanics/Water Tankers'),
('Dpt009', 'Mining Supervisors'),
('Dpt010', 'Excavator Operators'),
('Dpt011', 'Straight Day/Grader'),
('Dpt012', 'Dozer'),
('Dpt013', 'Pumps'),
('Dpt014', 'Shift HD Drivers (Tipper Truck)'),
('Dpt015', 'Plant Metallurgist'),
('Dpt016', 'Plant Maintenance (Site-3)'),
('Dpt017', 'Hoppers (Site-3)'),
('Dpt018', 'Gold Sorters/Cleaning Gangs'),
('Dpt019', 'Supervisors (HD Drivers)'),
('Dpt020', 'Coaster Bus Drivers/Others'),
('Dpt021', 'Utility Drivers'),
('Dpt022', 'Stores & Fuel'),
('Dpt023', 'Fuel Supply Drivers'),
('Dpt024', 'Security Guards'),
('Dpt025', 'Geology & Survey & Grade Control'),
('Dpt026', 'External Prospectors (Eshun)'),
('Dpt027', 'Environment & Safety Assistants'),
('Dpt028', 'Cleaners/Gardeners'),
('Dpt029', 'National Service Personnel'),
('Dpt030', 'Graduate Trainees'),
('Dpt031', 'MD’s Residence (COOK)'),
('Dpt032', 'Mr. Mohammed’s Residence (COOK)'),
('Dpt033', 'Visitors (INTERNS & MINCOM)');

-- Kitchen Staff
INSERT INTO kitchen_staff (company_id, name) VALUES 
('KIT1001', 'Madam Eunice');

-- ==========================================
-- SEEDING ROTATING WEEKLY MENU ITEMS
-- ==========================================
INSERT INTO menu_items (name, shift, description, price) VALUES 
-- Day Shift: Week 1 / Odd Weeks Rotation
('Rice', 'DAY', 'Monday (Week 1) - Served with Groundnut Soup', 0.00),
('Banku', 'DAY', 'Monday (Week 1) - Served with Groundnut Soup', 0.00),
('Fufu', 'DAY', 'Tuesday (Week 1)', 0.00),
('Yam', 'DAY', 'Tuesday (Week 1)', 0.00),
('Waakye', 'DAY', 'Wednesday (Week 1)', 0.00),
('Kokonte', 'DAY', 'Wednesday (Week 1)', 0.00),

-- Day Shift: Week 2 / Even Weeks Rotation
('Banku', 'DAY', 'Monday (Week 2) - Served with Groundnut Soup', 0.00),
('Yam', 'DAY', 'Monday (Week 2) - Served with Groundnut Soup', 0.00),
('Fufu', 'DAY', 'Tuesday (Week 2)', 0.00),
('Rice', 'DAY', 'Tuesday (Week 2)', 0.00),
('Waakye', 'DAY', 'Wednesday (Week 2)', 0.00),
('Kenkey', 'DAY', 'Wednesday (Week 2)', 0.00),

-- Day Shift: Fixed Weekly Days
('Jollof Rice', 'DAY', 'Thursday (All Weeks) - Served with Okro', 0.00),
('Banku with Okro', 'DAY', 'Thursday (All Weeks)', 0.00),
('Beans', 'DAY', 'Friday (All Weeks)', 0.00),
('Rice Ball (Omotuo)', 'DAY', 'Friday (All Weeks)', 0.00),

-- Night Shift: Rice only for all days
('Rice', 'NIGHT', 'Night Shift Standard Meal - Rice', 0.00);

-- ==========================================
-- SEEDING SUPERVISORS
-- ==========================================
INSERT INTO supervisors (company_id, name, department) VALUES 
('KGL001', 'Daniel Adjei', 'KGL Managerial Staff'),
('KGL002', 'Adiza Sandah', 'Administrative Staff'),
('KGL003', 'Kwame Mensah', 'Hard Rock/Exploration'),
('KGL004', 'Kofi Boateng', 'Rango(Workshop Builders)'),
('KGL005', 'Supervisor 05', 'Plant Maintenance (Site-1)'),
('KGL006', 'Supervisor 06', 'Hoppers (Site-1)');