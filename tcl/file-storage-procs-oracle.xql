<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="fs_get_root_folder.fs_root_folder">      
      <querytext>
      
	 begin
        	:1 := file_storage.get_root_folder(:package_id);
    	 end;

      </querytext>
</fullquery>

 
<fullquery name="fs_get_folder_name.folder_name">      
      <querytext>
      
    	begin
        	:1 := content_folder.get_label(:folder_id);
    	end;

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_perms">      
      <querytext>
      
    	select count(*)
    	from   cr_items
    	where  item_id in (select item_id
                       	   from   cr_items
                       	   connect by prior item_id = parent_id
                           start with item_id = :item_id)
    	and    acs_permission.permission_p(item_id,:user_id,:privilege) = 'f'

      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.child_items">      
      <querytext>
      
	select item_id as child_item_id
	from   cr_items
	connect by prior item_id = parent_id
	start with item_id = :item_id
    
      </querytext>
</fullquery>

 
<fullquery name="children_have_permission_p.revision_perms">      
      <querytext>
      
	select count(*)
	from   cr_revisions
	where  item_id = :child_item_id
	and    acs_permission.permission_p(revision_id,:user_id,:privilege) = 'f'

      </querytext>
</fullquery>

 
<fullquery name="fs_context_bar_list.title">      
      <querytext>

      	begin
	    :1 := content_item.get_title(:item_id);
	end;

      </querytext>
</fullquery>

 
<fullquery name="fs_context_bar_list.context_bar">      
      <querytext>
      
    	select case when content_item.get_content_type(i.item_id) = 'content_folder' 
	            then '?folder_id=' 
	             else 'file?file_id=' 
	       end || i.item_id,
               content_item.get_title(i.item_id)
    	from   cr_items i
    	where  item_id not in (
        		       	select i2.item_id
        			from   cr_items i2
        			connect by prior i2.parent_id = i2.item_id
        			start with i2.item_id = 
				    file_storage.get_root_folder([ad_conn package_id]))
    	connect by prior i.parent_id = i.item_id
    	start with item_id = :start_id
    	order by level desc

      </querytext>
</fullquery>
 
</queryset>
