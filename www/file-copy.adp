<master src="master">
<property name="title">Copy</property>
<property name="context">@context@</property>

<P>Select the folder that you would like to copy "@file_name@" to

<form method=GET action="file-copy-2">
<input type=hidden name=file_id value="@file_id@">

<include src="folder-list" file_id="">
<p>
<input type=submit value="Copy">
</form>
