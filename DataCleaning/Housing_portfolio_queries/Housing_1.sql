/*
An exploration and demo of data cleaning with Nasheville housing sales data
*/



SELECT *
FROM Portfolio_Project_Housing..NashevilleHousing


--Trimming and standardizing SaleDate format, getting rid of the time
--2013-04-09 00:00:00.000
SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Portfolio_Project_Housing..NashevilleHousing


--UPDATE NashevilleHousing
--SET SaleDate = CONVERT(date, SaleDate)
--This doesn't always work?

ALTER TABLE NashevilleHousing
ADD SaleDateConverted date;
UPDATE Portfolio_Project_Housing..NashevilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)





--Fixing NULL PropertyAddress values
SELECT *
FROM Portfolio_Project_Housing..NashevilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID
/*
In the data, it so happens that ParcelID and PropertyAddress coincide:
every pair of entries with identical ParcelID values have identical PropertyAddress values. 
Rows in the data have unique UniqueID values.

To attempt to fill in NULL PropertyAddress values, we can do a self-join.
(We use nondescriptive aliases A and B here since it's the same table.)
*/

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress,
	ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_Project_Housing..NashevilleHousing AS A
JOIN Portfolio_Project_Housing..NashevilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_Project_Housing..NashevilleHousing AS A
JOIN Portfolio_Project_Housing..NashevilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL





--Dividing PropertyAddress and OwnerAddress into separate columns for StreetAddress, City, State, etc.
SELECT PropertyAddress, OwnerAddress
FROM Portfolio_Project_Housing..NashevilleHousing
/*
In the data, it so happens that PropertyAddress uses a comma ',' to separate the street address from the city,
and OwnerAddress similarly for the state as well. (All states are TN here.)

CHARINDEX returns the index at which the first argument occurs within the second argument.
We cannot use negative indices a-la modular arithmetic.

We use the SUBSTRING function for PropertyAddress, and PARSENAME for OwnerAddress.
*/

SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS StreetAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Portfolio_Project_Housing..NashevilleHousing


ALTER TABLE NashevilleHousing
ADD PropertyAddressStreet nvarchar(255);
UPDATE Portfolio_Project_Housing..NashevilleHousing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashevilleHousing
ADD PropertyAddressCity nvarchar(255);
UPDATE Portfolio_Project_Housing..NashevilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))





--Same as above, but with OwnerAddress
SELECT OwnerAddress, PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3), --returns street address
	PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2), --returns city
	PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1) --returns TN
FROM Portfolio_Project_Housing..NashevilleHousing


ALTER TABLE Portfolio_Project_Housing..NashevilleHousing
ADD OwnerAddressStreet nvarchar(255);
UPDATE Portfolio_Project_Housing..NashevilleHousing
SET OwnerAddressStreet = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashevilleHousing
ADD OwnerAddressCity nvarchar(255);
UPDATE Portfolio_Project_Housing..NashevilleHousing
SET OwnerAddressCity = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashevilleHousing
ADD OwnerAddressState nvarchar(255);
UPDATE Portfolio_Project_Housing..NashevilleHousing
SET OwnerAddressState = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1)





--Consolidate redundant values in SoldAsVacant
--Y:52, N:399, Yes:4623, No:51403
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project_Housing..NashevilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Portfolio_Project_Housing..NashevilleHousing
--WHERE (SoldAsVacant LIKE 'Y' OR SoldAsVacant LIKE 'N')


UPDATE Portfolio_Project_Housing..NashevilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END





--Omitting/Deleting duplicate data
WITH Row_Count_CTE AS (
	SELECT *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID ) AS 'Row Count' 
	FROM Portfolio_Project_Housing..NashevilleHousing
)
/*
We wish to find values in the data which should be distinct but are the same, indicating duplicate rows.

In the PARTITION, rows showing a value of '2' or higher instead of '1' in the [Row Count] column
indicate a duplicate entry.

Deleting data is not necessarily best practice.
*/


SELECT *
--DELETE
FROM Row_Count_CTE
WHERE [Row Count] > 1
ORDER BY PropertyAddress





--Omitting/deleting unused columns
ALTER TABLE Portfolio_Project_Housing..NashevilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict


