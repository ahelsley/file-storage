# file-storage/www/folder-contents.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Apr 25, 2002
    @cvs-id $Id$
} -query {
    {folder_id:integer {[fs::get_root_folder]}}
    {recurse_p:boolean 0}
    {n_past_days:integer 999999}
    {orderby "name"}
} -validate {
    valid_folder -requires {folder_id:integer} {
        if {[empty_string_p $folder_id] || ![fs::folder_p -object_id $folder_id]} {
            ad_complain
        }
    }
} -errors {
    valid_folder {No valid folder was found}
} -properties {
    folder_id:onevalue
    folder_name:onevalue
    context:onevalue
    recurse_p:onevalue
    n_past_days:onevalue
    orderby:onevalue
    table:onevalue
}

set user_id [ad_verify_and_get_user_id]

form create n_past_days_form

set options {{All 999999} {1 1} {2 2} {3 3} {7 7} {14 14} {30 30}}
element create n_past_days_form n_past_days \
    -label "" \
    -datatype text \
    -widget select \
    -options $options \
    -html {onChange document.n_past_days_form.submit()} \
    -value $n_past_days

element create n_past_days_form folder_id \
    -label "[_ file-storage.Folder_ID]" \
    -datatype text \
    -widget hidden \
    -value $folder_id

element create n_past_days_form recurse_p \
    -label "[_ file-storage.Recurse]" \
    -datatype text \
    -widget hidden \
    -value $recurse_p

element create n_past_days_form orderby \
    -label "[_ file-storage.Order_By]" \
    -datatype text \
    -widget hidden \
    -value $orderby

if {[form is_valid n_past_days_form]} {
    form get_values n_past_days_form \
        n_past_days folder_id recurse_p orderby
}

set table_def [list]

lappend table_def [list name Name {fs_objects.name $order} "<td width=\"30%\"><a href=\"\[ad_decode \$type folder \"folder-contents?folder_id=\$object_id&n_past_days=$n_past_days&recurse_p=$recurse_p&orderby=$orderby\" url \"url-goto?url_id=\$object_id\" \"download/\$name?version_id=\$live_revision\"]\">\$name</a></td>"]
lappend table_def [list folder_name Folder {} "<td width=\"30%\"><a href=\"folder-contents?folder_id=\$parent_id&n_past_days=$n_past_days&recurse_p=$recurse_p&orderby=$orderby\">\$folder_name</a></td>"]
lappend table_def {type Type {fs_objects.type $order} {c}}
lappend table_def {content_size Size {fs_objects.content_size $order} {<td align=\"center\">[ad_decode $type folder "$content_size item[ad_decode $content_size 1 {} s]" url {} "$content_size byte[ad_decode $content_size 1 {} s]"]</td>}}
lappend table_def {last_modified {Last Modified} {fs_objects.last_modified $order} {<td align=\"center\">[lc_time_format $last_modified "%q"]</td>}}

#JCD BROKEN QUERY NEEDS db_map

if {$recurse_p} {
    set sql "
        select fs_objects.*,
            fs_folders.name as folder_name
        from fs_objects,
            fs_folders
        where fs_objects.object_id in (select acs_objects.object_id
                                       from acs_objects
                                       connect by acs_objects.context_id = prior acs_objects.object_id
                                       start with acs_objects.context_id = :folder_id)
        and fs_objects.parent_id = fs_folders.folder_id
        and fs_objects.type <> 'folder'
        and fs_objects.last_modified >= (sysdate - :n_past_days)
        and 't' = acs_permission.permission_p(fs_objects.object_id, :user_id, 'read')
        [ad_order_by_from_sort_spec $orderby $table_def]
    "
} else {
    set sql "
        select fs_objects.*,
            fs_folders.name as folder_name
        from fs_objects,
            fs_folders
        where fs_objects.parent_id = :folder_id
        and fs_folders.folder_id = :folder_id
        and fs_objects.last_modified >= (sysdate - :n_past_days)
        and 't' = acs_permission.permission_p(fs_objects.object_id, :user_id, 'read')
        [ad_order_by_from_sort_spec $orderby $table_def]
    "
}

set table [ad_table \
    -Torderby $orderby \
    -Tmissing_text "<blockquote><i>[_ file-storage.lt_Folder_folder_name_is] [list folder_name [fs::get_object_name -object_id $folder_id]]]</i></blockquote>" \
    -Ttable_extra_html {width="95%"} \
    select_folder_contents \
    $sql \
    $table_def
]

set folder_name [fs::get_object_name -object_id $folder_id]
set context [fs_context_bar_list -final Contents $folder_id]
