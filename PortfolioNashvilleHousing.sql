use Portfolio

select * 
from Portfolio..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

select SaleDate, CONVERT(date, SaleDate)as Sale_Date2
from Portfolio..NashvilleHousing

alter table NashvilleHousing
Add SaleDate2 Date; 


update NashvilleHousing
set SaleDate2 = CONVERT(date, SaleDate)


alter table Portfolio..NashvilleHousing
drop column SaleDate

----------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

select *
from Portfolio..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..NashvilleHousing a
join Portfolio..NashvilleHousing b
	on 
	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..NashvilleHousing a
join Portfolio..NashvilleHousing b
	on 
	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns(Address, City, State)

Select *
from Portfolio..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,len(PropertyAddress)) as City
from Portfolio..NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress varchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity varchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,len(PropertyAddress))


Select OwnerAddress
,PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from Portfolio..NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress varchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
Add OwnerSplitCity varchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
Add OwnerSplitState varchar(255)

update NashvilleHousing
set OwnerSplitState =PARSENAME(replace(OwnerAddress,',','.'),1)


----------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldAsVacant column

select distinct(SoldAsVacant)
from Portfolio..NashvilleHousing

select SoldAsVacant
,case
	when SoldAsVacant = 'Y'	then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end 
from Portfolio..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y'	then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

----------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


with RowNumCTE as
(
select *
,	ROW_NUMBER() over(
	partition by ParcelId,
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate2,
				 LegalReference
	order by uniqueID) row_num
from Portfolio..NashvilleHousing
)
select *
from RowNumCTE
where row_num >1


----------------------------------------------------------------------------------------------------------------------------------

--Remove Unused Columns

select *
from Portfolio..NashvilleHousing

alter table Portfolio..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict
