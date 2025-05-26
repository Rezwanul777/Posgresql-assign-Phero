-- Active: 1747667236987@@127.0.0.1@5432@conservation_db


-- ========================================
-- TABLE CREATION
-- ========================================

-- Create rangers table
CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

-- Create species table
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) NOT NULL
);

-- Create sightings table
CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INTEGER NOT NULL,
    species_id INTEGER NOT NULL,
    sighting_time TIMESTAMP NOT NULL,
    location VARCHAR(200) NOT NULL,
    notes TEXT,
    FOREIGN KEY (ranger_id) REFERENCES rangers(ranger_id),
    FOREIGN KEY (species_id) REFERENCES species(species_id)
);

-- ========================================
-- SAMPLE DATA INSERTION
-- ========================================

-- Insert rangers data
INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

-- Insert species data
INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

-- Insert sightings data
INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);

-- ========================================
-- PROBLEM SOLUTIONS
-- ========================================

-- Problem 1: Register a new ranger with name = 'Derek Fox' and region = 'Coastal Plains'
INSERT INTO rangers (name, region) VALUES ('Derek Fox', 'Coastal Plains');

-- Problem 2: Count unique species ever sighted
SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;

-- Problem 3: Find all sightings where the location includes "Pass"
SELECT sighting_id, species_id, ranger_id, location, sighting_time, notes
FROM sightings
WHERE location LIKE '%Pass%';

-- Problem 4: List each ranger's name and their total number of sightings
SELECT name, 
       (SELECT COUNT(*) FROM sightings WHERE ranger_id = r.ranger_id) AS total_sightings
FROM rangers r
ORDER BY name;

-- Problem 5: List species that have never been sighted
SELECT common_name
FROM species
WHERE NOT EXISTS (
    SELECT 1 FROM sightings WHERE species_id = species.species_id
);

-- Problem 6: Show the most recent 2 sightings
SELECT sp.common_name, s.sighting_time, r.name
FROM sightings s, species sp, rangers r
WHERE s.species_id = sp.species_id 
  AND s.ranger_id = r.ranger_id
ORDER BY s.sighting_time DESC
LIMIT 2;
-- Problem 7: Update all species discovered before year 1800 to have status 'Historic'
UPDATE species
SET conservation_status = 'Historic'
WHERE EXTRACT(YEAR FROM discovery_date) < 1800;

-- Problem 8: Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'
SELECT sighting_id,
       CASE
           WHEN sighting_time::time < '12:00:00' THEN 'Morning'
           WHEN sighting_time::time <= '17:00:00' THEN 'Afternoon'
           ELSE 'Evening'
       END AS time_of_day
FROM sightings
ORDER BY sighting_id;

-- Problem 9: Delete rangers who have never sighted any species
DELETE FROM rangers
WHERE ranger_id NOT IN (
    SELECT DISTINCT ranger_id 
    FROM sightings 
    WHERE ranger_id IS NOT NULL
);

-- ========================================
-- VERIFICATION QUERIES (Optional)
-- ========================================

-- Check final state of all tables
SELECT 'Rangers Table:' AS info;
SELECT * FROM rangers;

SELECT 'Species Table:' AS info;
SELECT * FROM species;

SELECT 'Sightings Table:' AS info;
SELECT * FROM sightings;