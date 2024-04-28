--- Check if a table named 'backlog' exists in the 'dbo' schema
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'backlog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- If the 'backlog' table does not exist, create it with columns 'id' and 'state'
    CREATE TABLE backlog (
        id INT IDENTITY(1,1) PRIMARY KEY, -- 'id' is an auto-incrementing integer
        state VARCHAR(50) -- 'state' is a variable character string with a maximum length of 50
    );
END

-- Count the number of rows in the 'backlog' table where 'state' is 'queued'
SELECT count(*) FROM backlog WHERE state = 'queued'

-- Declare a variable named '@counter' and initialize it with the value 1
DECLARE @counter INT = 1;

-- Start a loop that will run 50 times
WHILE @counter <= 50
BEGIN
    -- Insert a new row into the 'backlog' table with 'state' set to 'queued'
    INSERT INTO backlog (state) VALUES ('queued');
    
    -- Increment the '@counter' variable by 1
    SET @counter = @counter + 1;
END;

-- Count the number of rows in the 'backlog' table where 'state' is 'queued'
SELECT count(*) FROM backlog WHERE state = 'queued'

-- Delete all rows from the 'backlog' table
DELETE FROM backlog;
