
--
-- File Storage NonVersioned (simple) Objects
--
-- This is to get away from the CR pain when dealing with file-storage of
-- "other" objects
--
-- @author Ben Adida (ben@openforce)
-- @creation-date 01 April 2002
-- @cvs-id $Id$
--

create or replace package fs_simple_object
as

    function new (
        object_id in fs_simple_objects.object_id%TYPE default NULL,
        object_type in acs_objects.object_type%TYPE default 'fs_simple_object',
        folder_id in fs_simple_objects.folder_id%TYPE,
        name in fs_simple_objects.name%TYPE,
        description in fs_simple_objects.description%TYPE,
        creation_date in acs_objects.creation_date%TYPE default sysdate,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE,
        context_id in acs_objects.context_id%TYPE
    ) return fs_simple_objects.object_id%TYPE;

    procedure delete (
        object_id in fs_simple_objects.object_id%TYPE
    );

    function name (
        object_id in fs_simple_objects.object_id%TYPE
    ) return fs_simple_objects.name%TYPE;

end fs_simple_object;
/
show errors

create or replace package body fs_simple_object
as

    function new (
        object_id in fs_simple_objects.object_id%TYPE default NULL,
        object_type in acs_objects.object_type%TYPE default 'fs_simple_object',
        folder_id in fs_simple_objects.folder_id%TYPE,
        name in fs_simple_objects.name%TYPE,
        description in fs_simple_objects.description%TYPE,
        creation_date in acs_objects.creation_date%TYPE default sysdate,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE,
        context_id in acs_objects.context_id%TYPE
    ) return fs_simple_objects.object_id%TYPE
    is
        v_object_id                 acs_objects.object_id%TYPE;
    begin
        v_object_id:= acs_object.new (
            object_id => object_id,
            object_type => object_type,
            creation_date => creation_date,
            creation_user => creation_user,
            creation_ip => creation_ip,
            context_id => context_id
        );

        insert into fs_simple_objects
        (object_id, folder_id, name, description) values
        (v_object_id, folder_id, name, description);

        acs_object.update_last_modified(fs_simple_object.new.folder_id);

        return v_object_id;
    end new;

    procedure delete (
        object_id in fs_simple_objects.object_id%TYPE
    )
    is
    begin
        acs_object.delete(object_id);
    end delete;

    function name (
        object_id in fs_simple_objects.object_id%TYPE
    ) return fs_simple_objects.name%TYPE
    is
        v_name                      fs_simple_objects.name%TYPE;
    begin
        select name
        into v_name
        from fs_simple_objects
        where object_id = fs_simple_object.name.object_id;

        return v_name;
    end name;

end fs_simple_object;
/
show errors

create or replace package fs_url
as

    function new (
        url_id in fs_urls.url_id%TYPE default NULL,
        object_type in acs_objects.object_type%TYPE default 'fs_url',
        url in fs_urls.url%TYPE,
        folder_id in fs_simple_objects.folder_id%TYPE,
        name in fs_simple_objects.name%TYPE,
        description in fs_simple_objects.description%TYPE,
        creation_date in acs_objects.creation_date%TYPE default sysdate,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE,
        context_id in acs_objects.context_id%TYPE
    ) return fs_urls.url_id%TYPE;

    procedure delete (
        url_id in fs_urls.url_id%TYPE
    );

    function copy (
        url_id in fs_urls.url_id%TYPE,
        target_folder_id in fs_simple_objects.folder_id%TYPE
    ) return fs_urls.url_id%TYPE;

end fs_url;
/
show errors

create or replace package body fs_url
as

    function new (
        url_id in fs_urls.url_id%TYPE default NULL,
        object_type in acs_objects.object_type%TYPE default 'fs_url',
        url in fs_urls.url%TYPE,
        folder_id in fs_simple_objects.folder_id%TYPE,
        name in fs_simple_objects.name%TYPE,
        description in fs_simple_objects.description%TYPE,
        creation_date in acs_objects.creation_date%TYPE default sysdate,
        creation_user in acs_objects.creation_user%TYPE,
        creation_ip in acs_objects.creation_ip%TYPE,
        context_id in acs_objects.context_id%TYPE
    ) return fs_urls.url_id%TYPE
    is
        v_url_id fs_simple_objects.object_id%TYPE;
    begin
        v_url_id:= fs_simple_object.new (
            object_id => url_id,
            object_type => object_type,
            folder_id => folder_id,
            name => name,
            description => description,
            creation_date => creation_date,
            creation_user => creation_user,
            creation_ip => creation_ip,
            context_id => context_id
        );

        insert into fs_urls
        (url_id, url) values
        (v_url_id, url);

        return v_url_id;
    end new;

    procedure delete (
        url_id in fs_urls.url_id%TYPE
    )
    is
    begin
        delete from fs_urls where url_id= fs_url.delete.url_id;

        fs_simple_object.delete(url_id);
    end delete;

    function copy (
        url_id in fs_urls.url_id%TYPE,
        target_folder_id in fs_simple_objects.folder_id%TYPE
    ) return fs_urls.url_id%TYPE
    is
        v_new_url_id            fs_urls.url_id%TYPE;
        v_url                   fs_urls.url%TYPE;
        v_name                  fs_simple_objects.name%TYPE;
        v_description           fs_simple_objects.description%TYPE;
        v_creation_user         acs_objects.creation_user%TYPE;
        v_creation_ip           acs_objects.creation_ip%TYPE;
    begin

        select url
        into v_url
        from fs_urls
        where url_id = copy.url_id;

        select name, description 
        into v_name, v_description 
        from fs_simple_objects
        where object_id = copy.url_id;

        select creation_user, creation_ip
        into v_creation_user, v_creation_ip
        from acs_objects
        where object_id = copy.url_id;

        v_new_url_id := fs_url.new( 
            url           => v_url,
            folder_id     => copy.target_folder_id,
            name          => v_name,
            description   => v_description,
            creation_user => v_creation_user,
            creation_ip   => v_creation_ip,
            context_id    => copy.target_folder_id
        );

        return v_new_url_id;
    end copy;

end fs_url;
/
show errors
