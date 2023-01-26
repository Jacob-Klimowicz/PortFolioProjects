/*
Cleaning Dataset
*/

Select *
from portfolioproject.dbo.NashvilleHousing

---- Standardize Date Format

Select SaleDateconverted, CONVERT(Date,SaleDate)
From portfolioproject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-------------------------------------------------------------------------------------------------
---- Populate Property address Data

Select *
from portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress is Null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL



--------------------------------------------------------------------------------------
---- Breaking out PropertyAddress into Individual Columns (Address,City,State)
-- using CHARINDEX('') to find the delimiter 


Select PropertyAddress
from portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress is Null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress )-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS address
FROM portfolioproject.dbo.NashvilleHousing


ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress )-1)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Select *
--FROM portfolioproject.dbo.NashvilleHousing




-------------------------------------------------------------------------------------------------
-- Fixing Owneraddress into Individual Columns (Address,City,State)
-- using PARSENAME 

Select owneraddress	
FROM portfolioproject.dbo.NashvilleHousing

SELECT 
PARSENAME(Replace(owneraddress,',','.'),3),
PARSENAME(Replace(owneraddress,',','.'),2),
PARSENAME(Replace(owneraddress,',','.'),1)
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(owneraddress,',','.'),3)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(owneraddress,',','.'),2)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(owneraddress,',','.'),1)

--SELECT * 
--FROM portfolioproject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM portfolioproject.dbo.NashvilleHousing


UPDATE portfolioproject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--------------------------------------------------------------------------------------
-- Remove Duplicates
--SELECT * 
--FROM portfolioproject.dbo.NashvilleHousing

WITH rowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS row_num

FROM portfolioproject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num >1
--Order by PropertyAddress




-----------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate