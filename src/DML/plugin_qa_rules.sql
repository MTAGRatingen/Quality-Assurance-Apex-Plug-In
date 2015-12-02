prompt Importing table plugin_qa_rules...
set feedback off
set define off
insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (1, 'No Never Condition', 'APEX', 'REGION:ITEM:RPT_COL:BUTTON:COMPUTATION:VALIDATION:PROCESS:BRANCH:DA', 'Don''t use the never Condition', 'Working with never Conditions should be permitted.', 1, 1, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => ''APEX''
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => a.object_type
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => a.object_id
                       ,object_name         => a.object_name
                       ,object_value        => a.object_value
                       ,object_updated_user => a.object_updated_user
                       ,object_updated_date => a.object_updated_date
                       ,apex_app_id         => a.application_id
                       ,apex_page_id        => a.page_id
                       ,apex_region_id      => a.region_id)
from plugin_qa_rules piqa
    ,(select ''ITEM'' object_type
            ,pi.application_id
            ,pi.page_id
            ,pi.region_id
            ,pi.item_id object_id
            ,pi.item_name object_name
            ,pi.condition_type_code object_value
            ,pi.last_updated_by object_updated_user
            ,pi.last_updated_on object_updated_date
      from apex_application_page_items pi
      where pi.condition_type_code = ''NEVER''
      union
      select ''REGION'' object_type
            ,pr.application_id
            ,pr.page_id
            ,pr.region_id
            ,pr.region_id object_id
            ,pr.region_name object_name
            ,pr.condition_type_code object_value
            ,pr.last_updated_by object_updated_user
            ,pr.last_updated_on object_updated_date
      from apex_application_page_regions pr
      where condition_type_code = ''NEVER''
      union
      select ''BUTTON'' object_type
            ,pb.application_id
            ,pb.page_id
            ,pb.region_id
            ,pb.button_id object_id
            ,pb.button_name object_name
            ,pb.condition_type_code object_value
            ,pb.last_updated_by object_updated_user
            ,pb.last_updated_on object_updated_date
      from apex_application_page_buttons pb
      where pb.condition_type_code = ''NEVER''
      union
      select ''RPT_COL'' object_type
            ,prc.application_id
            ,prc.page_id
            ,prc.region_id
            ,prc.region_report_column_id object_id
            ,prc.column_alias object_name
            ,prc.condition_type_code object_value
            ,prc.last_updated_by object_updated_user
            ,prc.last_updated_on object_updated_date
      from apex_application_page_rpt_cols prc
      where prc.condition_type_code = ''NEVER''
      union
      select ''COMPUTATION'' object_type
            ,pc.application_id
            ,pc.page_id
            ,null region_id
            ,pc.computation_id object_id
            ,pc.computation object_name
            ,pc.condition_type_code object_value
            ,pc.last_updated_by object_updated_user
            ,pc.last_updated_on object_updated_date
      from apex_application_page_comp pc
      where pc.condition_type_code = ''NEVER''
      union
      select ''VALIDATION'' object_type
            ,pv.application_id
            ,pv.page_id
            ,null region_id
            ,pv.validation_id object_id
            ,pv.validation_name object_name
            ,pv.condition_type_code object_value
            ,pv.last_updated_by object_updated_user
            ,pv.last_updated_on object_updated_date
      from apex_application_page_val pv
      where pv.condition_type_code = ''NEVER''
', null, 'PAGE');

update plugin_qa_rules set piqa_sql = piqa_sql || '      union
      select ''PROCESS'' object_type
            ,pp.application_id
            ,pp.page_id
            ,null region_id
            ,pp.process_id object_id
            ,pp.process_name object_name
            ,pp.condition_type_code object_value
            ,pp.last_updated_by object_updated_user
            ,pp.last_updated_on object_updated_date
      from apex_application_page_proc pp
      where pp.condition_type_code = ''NEVER''
      union
      select ''BRANCH'' object_type
            ,pb.application_id
            ,pb.page_id
            ,null region_id
            ,pb.branch_id object_id
            ,pb.branch_point object_name
            ,pb.condition_type_code object_value
            ,pb.last_updated_by object_updated_user
            ,pb.last_updated_on object_updated_date
      from apex_application_page_branches pb
      where pb.condition_type_code = ''NEVER''
      union
      select ''DA'' object_type
            ,pd.application_id
            ,pd.page_id
            ,null region_id
            ,pd.dynamic_action_id object_id
            ,pd.dynamic_action_name object_name
            ,pd.condition_type_code object_value
            ,pd.last_updated_by object_updated_user
            ,pd.last_updated_on object_updated_date
      from apex_application_page_da pd
      where pd.condition_type_code = ''NEVER'') a
where piqa_id = :1
and a.application_id = :2
and a.page_id = :3' where PIQA_NAME = 'No Never Condition' and length(piqa_sql) < 4000;

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (2, 'Help Label without Help', 'APEX', 'ITEM', 'Item has no help text.', 'Item has no help text.', 1, 0, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => pi.item_id
                       ,object_name         => pi.item_name
                       ,object_value        => pi.item_help_text
                       ,object_updated_user => pi.last_updated_by
                       ,object_updated_date => pi.last_updated_on
                       ,apex_app_id         => pi.application_id
                       ,apex_page_id        => pi.page_id
                       ,apex_region_id      => pi.region_id)
from plugin_qa_rules piqa
    ,apex_application_page_items pi
where piqa_id = :1
and pi.application_id = :2
and pi.page_id = :3
and pi.item_help_text is null', '1', 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (3, 'Page without ALIAS', 'APEX', 'PAGE', 'Page has no ALIAS', 'Every Page should have an ALIAS.', 2, 1, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => p.page_id
                       ,object_name         => p.page_name
                       ,object_value        => p.page_alias
                       ,object_updated_user => p.last_updated_by
                       ,object_updated_date => p.last_updated_on
                       ,apex_app_id         => p.application_id
                       ,apex_page_id        => p.page_id
                       ,apex_region_id      => null)
from plugin_qa_rules piqa
    ,apex_application_pages p
where piqa_id = :1
and p.application_id = :2
and p.page_id = :3
and p.page_alias is null', null, 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (4, 'Page without Pagegroup', 'APEX', 'PAGE', 'Page has no Page Group', 'Every page should have a page group.', 2, 1, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => p.page_id
                       ,object_name         => p.page_name
                       ,object_value        => p.page_group
                       ,object_updated_user => p.last_updated_by
                       ,object_updated_date => p.last_updated_on
                       ,apex_app_id         => p.application_id
                       ,apex_page_id        => p.page_id
                       ,apex_region_id      => null)
from plugin_qa_rules piqa
    ,apex_application_pages p
where piqa_id = :1
and p.application_id = :2
and p.page_id = :3
and p.page_group is null', null, 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (5, 'Page is Public', 'APEX', 'PAGE', 'Page is Public', 'Warning for pages which are public.', 4, 1, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => p.page_id
                       ,object_name         => p.page_name
                       ,object_value        => p.page_requires_Authentication
                       ,object_updated_user => p.last_updated_by
                       ,object_updated_date => p.last_updated_on
                       ,apex_app_id         => p.application_id
                       ,apex_page_id        => p.page_id
                       ,apex_region_id      => null)
from plugin_qa_rules piqa
    ,apex_application_pages p
where piqa_id = :1
and p.application_id = :2
and p.page_id = :3
and p.page_requires_Authentication = ''NO''', null, 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (6, 'Named LOV', 'APEX', 'ITEM', 'No named LOV is used', 'Always use named LOV', 1, 1, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => pi.item_id
                       ,object_name         => pi.item_name
                       ,object_value        => pi.lov_named_lov
                       ,object_updated_user => pi.last_updated_by
                       ,object_updated_date => pi.last_updated_on
                       ,apex_app_id         => pi.application_id
                       ,apex_page_id        => pi.page_id
                       ,apex_region_id      => pi.region_id)
from plugin_qa_rules piqa
    ,apex_application_page_items pi
where piqa_id = :1
and pi.application_id = :2
and pi.page_id = :3
and pi.display_as_code in (''NATIVE_CHECKBOX'',''NATIVE_POPUP_LOV'',''NATIVE_RADIOGROUP'',''NATIVE_SELECT_LIST'',''NATIVE_YES_NO'')
and pi.lov_named_lov is null', '1', 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (7, 'Labels left', 'APEX', 'ITEM', 'Label Alignment is not left', 'Labels should be always aligned to left', 1, 1, 'select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => pi.item_id
                       ,object_name         => pi.item_name
                       ,object_value        => pi.LABEL_ALIGNMENT
                       ,object_updated_user => pi.last_updated_by
                       ,object_updated_date => pi.last_updated_on
                       ,apex_app_id         => pi.application_id
                       ,apex_page_id        => pi.page_id
                       ,apex_region_id      => pi.region_id)
from plugin_qa_rules piqa
    ,apex_application_page_items pi
where piqa_id = :1
and pi.application_id = :2
and pi.page_id = :3
and pi.LABEL_ALIGNMENT <> ''Left''
and pi.display_as <> ''Hidden''', '1', 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (12, 'Display Extra Value is Yes', 'APEX', 'ITEM', 'Display Extra Value is Yes', null, 2, 1, 'with param as (select :1 piqa_id, :2 app_id, :3 page_id from dual)
select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => aapi.item_id
                       ,object_name         => aapi.item_name
                       ,object_value        => aapi.lov_display_extra
                       ,object_updated_user => aapi.last_updated_by
                       ,object_updated_date => aapi.last_updated_on
                       ,apex_app_id         => aapi.application_id
                       ,apex_page_id        => aapi.page_id
                       ,apex_region_id      => null)
from plugin_qa_rules piqa
join param p on p.piqa_id = piqa.piqa_id
join apex_application_page_items aapi on aapi.application_id = p.app_id and aapi.page_id = p.page_id
where aapi.display_as = ''Checkbox''
and aapi.lov_display_extra = ''Yes''', null, 'PAGE');

insert into plugin_qa_rules (PIQA_ID, PIQA_NAME, PIQA_CATEGORY, PIQA_OBJECT_TYPES, PIQA_ERROR_MESSAGE, PIQA_COMMENT, PIQA_ERROR_LEVEL, PIQA_IS_ACTIVE, PIQA_SQL, PIQA_PREDECESSOR_IDS, PIQA_LAYER)
values (13, 'Display Dynamic Actions', 'APEX', 'DA', 'Show all Dynamic Actions on a page.', null, 1, 1, 'with param as (select :1 piqa_id, :2 app_id, :3 page_id from dual)
select t_plugin_qa_rule(piqa_id             => piqa.piqa_id
                       ,piqa_category       => piqa.piqa_category
                       ,piqa_error_level    => piqa.piqa_error_level
                       ,piqa_object_type    => piqa.piqa_object_types
                       ,piqa_error_message  => piqa.piqa_error_message
                       ,object_id           => aapd.dynamic_action_id
                       ,object_name         => aapd.dynamic_action_name
                       ,object_value        => aapd.dynamic_action_name
                       ,object_updated_user => aapd.last_updated_by
                       ,object_updated_date => aapd.last_updated_on
                       ,apex_app_id         => aapd.application_id
                       ,apex_page_id        => aapd.page_id
                       ,apex_region_id      => null)
from plugin_qa_rules piqa
join param p on p.piqa_id = piqa.piqa_id
join apex_application_page_da aapd on aapd.application_id = p.app_id and aapd.page_id = p.page_id', null, 'PAGE');

prompt Done.
