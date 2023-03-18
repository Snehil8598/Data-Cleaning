select *
from Housing
--Standardize Date Format

alter table Housing
add SaleDateConverted Date

update Housing
set SaleDateConverted=CONVERT(Date, SaleDate)

select SaleDateConverted
from Housing

alter table Housing
drop column SaleDate

---------------------------------------------------------------------------------------------------------------

--Populate property address data
select *
from Housing
--where PropertyAddress is null
order by ParcelID

select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
join Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where b.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
join Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select *
from Housing
where PropertyAddress is null

------------------------------------------------------------------------------------------------------------

--Breaking address into individual columns(address, city, state)
select
SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from Housing

alter table Housing
add PropertySplitAddress nvarchar(255)

update Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress)-1)

alter table Housing
add PropertyAddressCity nvarchar(255)

update Housing
set PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select
PARSENAME(replace(OwnerName,',','.'),3),
PARSENAME(replace(OwnerName,',','.'),2),
PARSENAME(replace(OwnerName,',','.'),1)
from Housing

alter table Housing
add OwnerSplitAddress nvarchar(255)

update Housing
set OwnerSplitAddress = PARSENAME(replace(OwnerName,',','.'),3)

alter table Housing
add OwnerAddressCity nvarchar(255)

update Housing
set OwnerAddressCity = PARSENAME(replace(OwnerName,',','.'),2)

alter table Housing
add OwnerAddressState nvarchar(255)

update Housing
set OwnerAddressState = PARSENAME(replace(OwnerName,',','.'),1)


select *
from Housing
--------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'SoldAsVacant'
select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Housing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end
from Housing

update Housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end
from Housing

----------------------------------------------------------------------------------------------------

--Removing Duplicates
with RowNumCTE as(
select *,
row_number() over(
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDateConverted,
LegalReference
order by
UniqueID
)row_num
from Housing
)
--delete
--from RowNumCTE
--where row_num>1

select *
from RowNumCTE
where row_num>1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------------------------

--Deleting unwanted columns
select *
from Housing

alter table Housing
drop column OwnerAddress, PropertyAddress, TaxDistrict