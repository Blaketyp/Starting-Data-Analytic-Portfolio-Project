--Cleaning Data in SQL Queries

Select * from [Data cleaning1].dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, convert(date,saledate)
from [Data cleaning1].dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,saledate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
Set SaleDateConverted = convert(date,saledate)


---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
from [Data cleaning1].dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Data cleaning1].dbo.NashvilleHousing a
join [Data cleaning1].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Data cleaning1].dbo.NashvilleHousing a
join [Data cleaning1].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual column (address, city, state)

Select PropertyAddress from [Data cleaning1].dbo.NashvilleHousing

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) as Address

from [Data cleaning1].dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAdress nvarchar(255);

update NashvilleHousing
Set PropertySplitAdress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))


select owneraddress from [Data cleaning1].dbo.NashvilleHousing


select 
parsename(replace(owneraddress,',','.'),3)
,parsename(replace(owneraddress,',','.'),2)
,parsename(replace(owneraddress,',','.'),1)
from [Data cleaning1].dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAdress nvarchar(255);

update NashvilleHousing
Set OwnerSplitAdress = parsename(replace(owneraddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = parsename(replace(owneraddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = parsename(replace(owneraddress,',','.'),1)


select * from [Data cleaning1].dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(soldasvacant) 
from [Data cleaning1].dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [Data cleaning1].dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
	end



---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

With rownumCTE as (
Select *,
	ROW_NUMBER() over (
	partition by 
	ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	order by
		UniqueID
		) row_num
from [Data cleaning1].dbo.NashvilleHousing
--order by ParcelID
)
Delete
from rownumCTE
where row_num > 1
--order by PropertyAddress



---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns

select * 
from [Data cleaning1].dbo.NashvilleHousing

alter table [Data cleaning1].dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table [Data cleaning1].dbo.NashvilleHousing
drop column saledate