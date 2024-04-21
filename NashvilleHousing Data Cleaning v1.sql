/*

Cleaning Data in SQL Queries

*/

select * from NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select SaleDate, CONVERT(DATE, SaleDate)
from NashvilleHousing;

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate) -- for some reason it is not working

--comment from the comments section:
/*Not sure if this has been pointed out, but the reason the SaleDate column didn't "update" here 
  is because UPDATE does not change data types. 
  The table is actually updating, but the data type for the column SaleDate is still datetime.*/

alter table NashvilleHousing
add SaleDateConverted DATE

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted
from NashvilleHousing;

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- everywhere where we have 2 or more same ParcelIDs, and some of the PropertyAddresses is not populated,
-- set it to be the same as one for that ParcelID for which the PropertyAddress exists

select *
from NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID


select n1.[UniqueID ], n1.ParcelID, n1.PropertyAddress, 
	   n2.[UniqueID ], n2.ParcelID, n2.PropertyAddress,
	   ISNULL(n1.PropertyAddress, n2.PropertyAddress) as corrected_value
from NashvilleHousing as n1
join NashvilleHousing as n2
on n1.ParcelID = n2.ParcelID 
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is NULL 



update n1
set n1.PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from NashvilleHousing as n1
join NashvilleHousing as n2
on n1.ParcelID = n2.ParcelID 
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is NULL 



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select *
from NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

select PropertyAddress, CHARINDEX(',', PropertyAddress) as position, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, len(PropertyAddress) ) as city
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) 

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, len(PropertyAddress) )


select OwnerAddress
from NashvilleHousing


select OwnerAddress,
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as city 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as state
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant =
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with cte as(
select [UniqueID ], ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference,
ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
																order by [UniqueID ]) as row_num
from NashvilleHousing
)
select * from cte 
where row_num > 1

--delete from cte 
--where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate



















