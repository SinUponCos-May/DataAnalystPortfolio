-- Data Cleaning Practice
-- Nashville Housing Data

Select * 
from NewProj..housingData

-- Standardizing the Date Format

select SaleDate,convert(date,SaleDate)
from NewProj..housingData

Alter table housingData
add ConvertedDate date;

Update housingData
set ConvertedDate = convert(date,SaleDate)

select * from housingData

-- Populating empty PropertyAddress

select *
from housingData
where PropertyAddress is null

select a.ParcelID,a.[UniqueID ],a.PropertyAddress,b.ParcelID,b.PropertyAddress,b.[UniqueID ]
from housingData a
join housingData b
 on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from housingData a
join housingData b
	on a.ParcelID = b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking the Address into individual Columns

select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as ConvertedAddress
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as ConvertedCity
from housingData

alter table housingData
add ConvertedAddress nvarchar(255);

update housingData
set ConvertedAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table housingData
add ConvertedCity nvarchar(255);

update housingData
set ConvertedCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Owner Address

select OwnerAddress , 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from housingData

alter table housingData
add SplitOwnerAddress nvarchar(255)

update housingData
set SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table housingData
add SplitOwnerCity nvarchar(255)

update housingData
set SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table housingData
add SplitOwnerState nvarchar(255)

update housingData
set SplitOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Converting Y and N to Yes and No

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from housingData
group by SoldAsVacant

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
from housingData

Update housingData
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
