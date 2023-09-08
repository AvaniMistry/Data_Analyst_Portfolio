-- Cleaning data in SQL Queries --

SELECT * FROM dbo.NashvilleHousing

-- Standardize date Format

	SELECT SaleDateConverted, CONVERT(date,SaleDate)
	FROM PortfolioProjectDB..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-------------------------------------------------------------------------------


-- Populate Property Address Data
	
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

-------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress FROM NashvilleHousing

SELECT
PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCitySplit Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCitysSplit Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCitysSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerStateSplit Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-------------------------------------------------------------------------------


-- Change Y & N to Yes & NO in SoldAs Vacent Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing)
--ORDER BY	ParcelID
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-------------------------------------------------------------------------------
	

--Delete unused columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict