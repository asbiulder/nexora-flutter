-- Classify the final Finger Soccer catalogue for the administrator shop.
-- Client categories are clubs, nations, cars, luxury brands and sports brands; team_kind uses singular stable keys.

update public.nx_catalog
   set team_kind = case
     when item_id like 'fs_team:club%' then 'club'
     when item_id like 'fs_team:nat%' then 'nation'
     when item_id like 'fs_team:car%' then 'car'
     when item_id like 'fs_team:lux%' then 'luxury'
     when item_id like 'fs_team:spt%' then 'sport'
     else team_kind
   end,
       updated_at = now()
 where active
   and item_id like 'fs_team:%';
