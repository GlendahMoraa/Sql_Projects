-----------------------------------------------------------------------------------------------------------------------------------------------
select * from Nashville_Housing




--Cleaning Data
---------------------------------------------------------------------------------------------------------------------------------------------------

-----Standadize Date Format
Alter table Nashville_Housing
add [Date] date

update Nashville_Housing
set [Date] = CONVERT(Date, SaleDate)

select date from Nashville_Housing

---------------------------------------------------------------------------------------------------------------------------------------------------

---Populate property adress data
Select * from Nashville_Housing

Select Nash1.ParcelId, Nash1.PropertyAddress, Nash2.ParcelId, Nash2.PropertyAddress, isnull(Nash1.PropertyAddress, Nash2.PropertyAddress)
from dbo.Nashville_Housing Nash1
join dbo.Nashville_Housing Nash2
	on Nash1.ParcelId = Nash2.ParcelId
	AND Nash1.[UniqueID ] < > Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

update Nash1
SET PropertyAddress = isnull(Nash1.PropertyAddress, Nash2.PropertyAddress)
from dbo.Nashville_Housing Nash1
join dbo.Nashville_Housing Nash2
	on Nash1.ParcelId = Nash2.ParcelId
	AND Nash1.[UniqueID ] < > Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------------------------

---Breaking out Adress into Indiviadual columns (Adress, City, state) using property address column

Alter table Nashville_Housing
add SplitedAdress nvarchar(255)

Alter table Nashville_Housing
add SplitedCity nvarchar(255)

update Nashville_Housing
set SplitedAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

update Nashville_Housing
set SplitedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

---Breaking out Adress into Indiviadual columns (Adress, City, state) using owner adress column

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.', 1) 
from Nashville_Housing

Alter table Nashville_Housing
add OwnerAdress nvarchar(255)

Alter table Nashville_Housing
add OwnerCity nvarchar(255)

Alter table Nashville_Housing
add OwnerState nvarchar(255)

update Nashville_Housing
set OwnerAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3) 

update Nashville_Housing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2) 

update Nashville_Housing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--parsename works with periods(.) Thats why we replace comas with periods in this case

select * from Nashville_Housing

----------------------------------------------------------------------------------------------------------------------------------------------

---Change Y and N to Yes and No in 'sold as vacant'field

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
END
from Nashville_Housing

--updating
Update Nashville_Housing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END

select SoldAsVacant, count(SoldAsVacant) from Nashville_Housing
group by SoldAsVacant

----------------------------------------------------------------------------------------------------------------------------------------------

---Remove duplicates
with Row_numCTE 
as
(select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDAte,
								LegalReference
								order by 
								UniqueID) row_num
from Nashville_Housing)
DELETE from Row_numCTE 
where row_num > 1

---sheck if duplicates we removed
with Row_numCTE 
as
(select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDAte,
								LegalReference
								order by 
								UniqueID) row_num
from Nashville_Housing)
select * from Row_numCTE 
where row_num > 1


----------------------------------------------------------------------------------------------------------------------------------------------

---Delete unused columns

alter table Nashville_Housing
drop column PropertyAddress, OwnerAdress, TaxDistrict, SalePrice

select * from Nashville_Housing