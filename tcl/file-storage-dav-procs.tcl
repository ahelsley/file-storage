# 

ad_library {
    
    Procedures for DAV service contract implementations
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2003-11-09
    @cvs-id $Id$
    
}

namespace eval fs::impl::fs_object {}

ad_proc fs::impl::fs_object::get {} {
    GET method
} {
    return [oacs_dav::impl::content_revision::get]
}

ad_proc fs::impl::fs_object::put {} {
    PUT method
} {
    set user_id [oacs_dav::conn user_id]
    set item_id [oacs_dav::conn item_id]
    set root_folder_id [oacs_dav::conn folder_id]
    set uri [oacs_dav::conn url]
    
    set tmp_filename [oacs_dav::conn tmpfile]
    set tmp_size [file size $tmp_filename]
    # authenticate that user has write privilege

    # we need to calculate parent_id from the URI
    # it might not be the root DAV folder for the package
    # check for folder or not

    set name [oacs_dav::conn item_name]
    set parent_id [oacs_dav::item_parent_folder_id $uri]
    array set sn [site_node::get -url $uri]
    set package_id $sn(package_id)
    if {[empty_string_p $parent_id]} {
	set response [list 409]
	return $response
    }

    if { ! [permission::permission_p \
		     -object_id $parent_id \
		     -party_id $user_id \
		     -privilege "create"
	      ]} {
	return [list 401]
    }

    if {![empty_string_p $item_id]} {
	if {![permission::permission_p \
		  -object_id $item_id \
		  -party_id $user_id \
		  -privilege "write"
	     ]} {
	    return [list 401]
	}
    }
    
        fs::add_file \
        -package_id $package_id \
        -name $name \
	-item_id $item_id \
	-parent_id $parent_id \
	-tmp_filename $tmp_filename \
	-creation_user $user_id \
	-creation_ip [ad_conn peeraddr] \
    
    set response [list 201]

    return $response

}

ad_proc fs::impl::fs_object::propfind {} {
    PROPFIND method
} {
    return [oacs_dav::impl::content_revision::propfind]
}

ad_proc fs::impl::fs_object::delete {} {
    DELETE method
} {
    return [oacs_dav::impl::content_revision::delete]
}

ad_proc fs::impl::fs_object::mkcol {} {
    MKCOL method
    not valid for resource
} {
    return [list 409]
}

ad_proc fs::impl::fs_object::proppatch {} {
    PROPPATCH method
} {
    # this is handled in tDAV for now
    return [list 201]
}

ad_proc fs::impl::fs_object::copy {} {
    COPY method
} {
    return [oacs_dav::impl::content_revision::copy]
}

ad_proc fs::impl::fs_object::move {} {
    MOVE method
} {
    return [oacs_dav::impl::content_revision::move]
}

namespace eval fs::impl::dav_put_type {}

ad_proc fs::impl::dav_put_type::get_type {} {

} {
    return "file_storage_object"
}