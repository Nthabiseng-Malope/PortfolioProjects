/*CLEANING DATA IN SQL QUERIES*/

Select * 
from PortfolioSql..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
select SaleDateConverted, Convert(Date,SaleDate)
from PortfolioSql..NashvilleHousing

Update NashvilleHousing set SaleDate = Convert(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing set SaleDateConverted = Convert(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate property address data
Select PropertyAddress
from PortfolioSql..NashvilleHousing
where PropertyAddress is NULL

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioSql..NashvilleHousing a
JOIN PortfolioSql..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioSql..NashvilleHousing a
JOIN PortfolioSql..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns (address, city, state)

--1. For property address and property city
select SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as address
from PortfolioSql..NashvilleHousing

select SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,charindex(',',PropertyAddress) + 1 , LEN(PropertyAddress))as address
from PortfolioSql..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress) + 1 , LEN(PropertyAddress))

Select * 
from PortfolioSql..NashvilleHousing

--2.For owners address
Select PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioSql..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


Select * 
from PortfolioSql..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field
Select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioSql..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from PortfolioSql..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove duplicates
WITH RowNumCTE AS(
Select * ,
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				UniqueID) row_num
from PortfolioSql..NashvilleHousing)
delete from RowNumCTE
where row_num > 1
--order by PropertyAddress

Select * 
from PortfolioSql..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns
Select * 
from PortfolioSql..NashvilleHousing

alter table PortfolioSql..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioSql..NashvilleHousing
drop column SaleDate




