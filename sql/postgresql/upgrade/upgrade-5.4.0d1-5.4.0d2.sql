update apm_parameters set default_value = 'zip' where parameter_name = 'ArchiveExtension';
update apm_parameters set default_value = '/usr/bin/zip -r {out_file} {in_file}' where parameter_name = 'ArchiveCommand';
update apm_parameter_values set attr_value = '/usr/bin/zip -r {out_file} {in_file}' where parameter_id = (select parameter_id from apm_parameters where parameter_name = 'ArchiveExtension');
update apm_parameter_values set attr_value = 'zip' where parameter_id = (select parameter_id from apm_parameters where parameter_name = 'ArchiveCommand');