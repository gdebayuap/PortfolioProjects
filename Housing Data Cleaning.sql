-- This is my second project by following AlexTheAnalyst Youtube Video -- https://www.youtube.com/watch?v=8rO7ztF4NtU
-- And for the dataset Nashville Housing -- https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data

-- We  want to clean the data in this table

-- First we look at the table
SELECT
	*
FROM
	PortfolioProject..HousingData

-- We need to convert datatype in SaleDate column from datetime to date and update it to table
UPDATE 	PortfolioProject..HousingData 
SET SaleDate =  CONVERT(date, SaleDate)

ALTER TABLE PortfolioProject..HousingData
ALTER COLUMN SaleDate date

-- We want to populate PropertyAddress data (There are NULL data in PropertyAddress column)
-- First we want to make sure that there are NULL data by looking at the column and filtered it
SELECT
	ParcelID, PropertyAddress
FROM
	PortfolioProject..HousingData
--WHERE
--	PropertyAddress is NULL
ORDER BY
	ParcelID

-- After looking, we know that this null datas in PropertyAddress have same ParcelID with the one that has data and to make sure we use this query
SELECT
	a.ParcelID, a.PropertyAddress,
	b.ParcelID, b.PropertyAddress
FROM
	PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	ON  a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress is null;

-- Update the table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	ON  a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress is null;

-- We want to split out PropertyAddress into individual columns (Address, City)
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM
	PortfolioProject..HousingData

-- Update the table by create more colummns (property_address, property_city)
ALTER TABLE PortfolioProject..HousingData
ADD property_address nvarchar(255);

UPDATE PortfolioProject..HousingData
SET property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE PortfolioProject..HousingData
ADD property_city nvarchar(255);

UPDATE PortfolioProject..HousingData
SET property_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

-- Next, we want to split out OwnerAddress into individual columns (Address, City, State)
SELECT
	OwnerAddress
FROM
	PortfolioProject..HousingData

--SELECT
--	a.ParcelID, a.OwnerAddress,
--	b.ParcelID, b.OwnerAddress
--FROM
--	PortfolioProject..HousingData a
--JOIN PortfolioProject..HousingData b
--	ON  a.ParcelID = b.ParcelID
--	AND a.UniqueID <> b.UniqueID
--WHERE
--	a.OwnerAddress is null;

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS split_owner_addr,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS split_owner_city,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS split_owner_state
FROM
	PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
ADD split_owner_addr nvarchar(255);

UPDATE PortfolioProject..HousingData
SET split_owner_addr = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject..HousingData
ADD split_owner_city nvarchar(255);

UPDATE PortfolioProject..HousingData
SET split_owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject..HousingData
ADD split_owner_state nvarchar(255);

UPDATE PortfolioProject..HousingData
SET split_owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT
	*
FROM
	PortfolioProject..HousingData

-- Change 'Y' and 'N' value to 'Yes' and 'No' in SoldAsVacant column
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	PortfolioProject..HousingData
GROUP BY
	SoldAsVacant
ORDER BY
	SoldAsVacant

SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM
	PortfolioProject..HousingData

UPDATE PortfolioProject..HousingData
SET 
	SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	PortfolioProject..HousingData
GROUP BY
	SoldAsVacant

-- Remove duplicate data
WITH row_num_temp AS (     -- create CTE to later use
SELECT
	*,
	ROW_NUMBER() OVER (    -- to get the number of duplicates
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				 ) AS row_num
FROM
	PortfolioProject..HousingData
)
DELETE  -- delete the duplicates
FROM
	row_num_temp
WHERE
	row_num > 1

SELECT  -- check table after delete the duplicates
	*
FROM
	row_num_CTE
WHERE
	row_num

-- Last, we want to eliminate the columns that are useless to further analysis
SELECT
	*
FROM
	PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
DROP COLUMN 
	PropertyAddress,   -- drop this because we already splitted it before
	TaxDistrict,	   -- we dont need this :)
	OwnerAddress       -- drop this because we already splitted it before
