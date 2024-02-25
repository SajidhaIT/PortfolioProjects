Select * 
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, CONVERT(date,SaleDate) 
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted date

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

Select SaleDateConverted, CONVERT(date,SaleDate) 
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------

--Populate Property Address data

Select * 
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress  
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID 

--Using SUBSTRING()
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address01
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

--Using PARSENAME()
Select OwnerAddress  
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 

--------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant 
order by 2

Select SoldAsVacant,
	Case
		When SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		ELSE SoldAsVacant 
	END
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = Case
						When SoldAsVacant='Y' then 'Yes'
						When SoldAsVacant='N' then 'No'
						ELSE SoldAsVacant 
					END

------------------------------------------------------------------

--Remove Duplicates 

Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID) as row_num

from PortfolioProject.dbo.NashvilleHousing
order by ParcelID 


--Using CTE

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID) as row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID 
)
Select * 
from RowNumCTE 
where row_num > 1
order by PropertyAddress 


--REMOVE Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID) as row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID 
)
Delete
from RowNumCTE 
where row_num > 1

----------------------------------------------------------------------------

--Delete Unused Columns

Select *
from PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Drop Column  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------