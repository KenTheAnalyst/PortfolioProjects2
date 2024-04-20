/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM NashVilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT 
	SaleDate
	, CONVERT(date, SaleDate)
FROM NashVilleHousing

UPDATE NashVilleHousing
SET SaleDate = CONVERT(date, SaleDate)


-- If it doesn't Update properly

ALTER TABLE NashVilleHousing
ADD SaleDateConverted Date; 

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT 
	SaleDateConverted
	, CONVERT(date, SaleDate)
FROM NashVilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashVilleHousing
WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT 
	a.ParcelID 
	, a.PropertyAddress 
	, b.ParcelID 
	, b.PropertyAddress
	, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashVilleHousing AS a
JOIN NashVilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM NashVilleHousing AS a
	JOIN NashVilleHousing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ] 
	WHERE a.PropertyAddress IS NULL 

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashVilleHousing

SELECT
	PropertyAddress
	, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address 
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address 
FROM NashVilleHousing


ALTER TABLE NashVilleHousing 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing 
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM NashVilleHousing


SELECT OwnerAddress
FROM NashVilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
	, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashVilleHousing

ALTER TABLE NashVilleHousing 
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashVilleHousing 
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashVilleHousing 
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashVilleHousing






--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
	DISTINCT(SoldAsVacant) 
	, COUNT(SoldAsVacant)
FROM NashVilleHousing
GROUP BY SoldAsVacant 
ORDER BY 2 

SELECT 
	SoldAsVacant
	, CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
FROM NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *
	, ROW_NUMBER() OVER (
	  PARTITION BY 
				   ParcelID
				   , PropertyAddress 
				   , SaleDate 
				   , SalePrice
				   , LegalReference
				   ORDER BY UniqueID
				   ) AS rownumber
FROM NashVilleHousing
--ORDER BY ParcelID
)

--DELETE 
--FROM RowNumCTE
--WHERE rownumber > 1 
----ORDER BY PropertyAddress

SELECT * 
FROM RowNumCTE
WHERE rownumber > 1 
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict 
















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















