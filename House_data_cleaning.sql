use house_proj;
-- drop table if exists house_data
 select *
 from house_data
 where PropertyAddress is null;

-- alter table house_data
-- add primary key(UniqueID);

--  filling the none Property Address
Update house_data, (
select a.UniqueID, a.ParcelID, b.PropertyAddress
from house_data as a
join house_data as b 
on a.UniqueID !=b.UniqueID and a.ParcelID=b.ParcelID
where a.PropertyAddress is null and b.PropertyAddress is not null
order by a.ParcelID
) as new_table
set
house_data.PropertyAddress= new_table.PropertyAddress
where house_data.UniqueID = new_table.UniqueID ;

-- break address into addess, city, state
select substring_index(PropertyAddress, ',',1) as Address, substring_index(PropertyAddress, ',',-1) as City
from house_data;

Alter table house_data
drop split_city,
drop split_address,
add split_address varchar(256) after PropertyAddress,
add split_city varchar(256) after split_address;

update house_data
set split_address=substring_index(PropertyAddress, ',',1);

update house_data
set split_city=substring_index(PropertyAddress, ',',-1);

-- change Y and N to yes and no
select SoldAsVacant,
(Case SoldAsVacant
when 'N' then 'No'
when 'Y' then 'Yes'
else SoldAsVacant 
end ) as modified_SoldAsVacant
from house_data;


update house_data
set SoldAsVacant=
(Case SoldAsVacant
when 'N' then 'No'
when 'Y' then 'Yes'
else SoldAsVacant 
end );


-- remove duplicates
delete from house_data
where UniqueID in
(select UniqueID
from
(select *, row_number() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerAddress order by ParcelID) as Sale_row_number
from house_data) as new_table1
where Sale_row_number>1)

--
--
