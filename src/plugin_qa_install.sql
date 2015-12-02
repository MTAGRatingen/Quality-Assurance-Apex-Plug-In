set serveroutput on;

PROMPT create table PLUGIN_QA_RULES
declare
  l_sql varchar2(32767) := 
'create table PLUGIN_QA_RULES
(
  piqa_id              NUMBER not null,
  piqa_name            VARCHAR2(100) not null,
  piqa_category        VARCHAR2(10) not null,
  piqa_object_types    VARCHAR2(4000) not null,
  piqa_error_message   VARCHAR2(4000) not null,
  piqa_comment         VARCHAR2(4000),
  piqa_exclude_objects VARCHAR2(4000),
  piqa_error_level     NUMBER not null,
  piqa_is_active       NUMBER default 1 not null,
  piqa_sql             CLOB not null,
  piqa_predecessor_ids VARCHAR2(4000),
  piqa_layer           VARCHAR2(100),
  piqa_created_on      DATE default sysdate not null,
  piqa_created_by      VARCHAR2(50) default user not null,
  piqa_updated_on      DATE default sysdate not null,
  piqa_updated_by      VARCHAR2(50) default user not null
)';
  l_count number;
begin

  select count(1) into l_count
  from user_objects u
  where u.object_name = 'PLUGIN_QA_RULES';
  
  if l_count = 0
  then
    execute immediate l_sql;
	execute immediate 'create unique index PIQA_PK_I on PLUGIN_QA_RULES (PIQA_ID)';
	execute immediate 'create unique index PIQA_UK_I on PLUGIN_QA_RULES (PIQA_NAME)';
	execute immediate 'alter table PLUGIN_QA_RULES add constraint PIQA_PK primary key (PIQA_ID)';
	execute immediate 'alter table PLUGIN_QA_RULES add constraint PIQA_UK unique (PIQA_NAME)';
	execute immediate q'#alter table PLUGIN_QA_RULES add constraint PIQA_CHK_CATEGORY check (PIQA_CATEGORY in ('APEX','DDL','DATA'))#';
	execute immediate 'alter table PLUGIN_QA_RULES add constraint PIQA_CHK_ERROR_LEVEL check (PIQA_ERROR_LEVEL in (1,2,4))';
	execute immediate 'alter table PLUGIN_QA_RULES add constraint PIQA_CHK_IS_ACTIVE check (PIQA_IS_ACTIVE in (0,1))';
	execute immediate 'alter table PLUGIN_QA_RULES add constraint PIQA_CHK_SQL check (length(PIQA_SQL) <= 32767)';
	
	dbms_output.put_line('Table PLUGIN_QA_RULES has been created.');
  else
  
    dbms_output.put_line('Table PLUGIN_QA_RULES was alread created.');
  end if;
  
exception
  when others then
    dbms_output.put_line('Table PLUGIN_QA_RULES could not been created.' || SQLERRM);
end;
/

comment on table PLUGIN_QA_RULES
  is 'Table for the rules defined for the APEX QA Plugin (v 0.1)';
comment on column PLUGIN_QA_RULES.piqa_id
  is 'pk column';
comment on column PLUGIN_QA_RULES.piqa_name
  is 'name of the rule. is shown when activating rules or as a headline in the output region of the plugin';
comment on column PLUGIN_QA_RULES.piqa_category
  is 'the category can be APEX, DDL or DATA and defines for the rules are used';
comment on column PLUGIN_QA_RULES.piqa_object_types
  is 'for every category there are different objecttypes. insert a colon delimited list.';
comment on column PLUGIN_QA_RULES.piqa_error_message
  is 'this message is given when the rule mismatches';
comment on column PLUGIN_QA_RULES.piqa_comment
  is 'further information for this rule';
comment on column PLUGIN_QA_RULES.piqa_exclude_objects
  is 'objects which should be excluded when using this rule. a colon delimted list of names';
comment on column PLUGIN_QA_RULES.piqa_error_level
  is 'different levels can be filtered out when runing the rules (1=Error, 2=Warning, 4=Info)';
comment on column PLUGIN_QA_RULES.piqa_is_active
  is 'is rule active=1 or inactive=0';
comment on column PLUGIN_QA_RULES.piqa_sql
  is 'sql query based on the supported type t_plugin_rule the query returns an amount of lines which is not fitting the rule. the length can be at maximum 32767 char';
comment on column PLUGIN_QA_RULES.piqa_predecessor_ids
  is 'colon delimted list of predecessors (PIQA_ID). the rule will only be executed if there are no errors found for the predecessor';
comment on column PLUGIN_QA_RULES.piqa_layer
  is 'is this rule related to objects on a single apex page (PAGE), to the apex application (APPLICATION) or to the database (DATABASE)';
comment on column PLUGIN_QA_RULES.piqa_created_on
  is 'when is the rule created';
comment on column PLUGIN_QA_RULES.piqa_created_by
  is 'who has the rule created';
comment on column PLUGIN_QA_RULES.piqa_updated_on
  is 'when is the rule updated';
comment on column PLUGIN_QA_RULES.piqa_updated_by
  is 'who has the rule updated';

PROMPT create or replace type t_plugin_qa_rule force as object
create or replace type t_plugin_qa_rule force as object
(
-- Information based on the rule
  piqa_id             number, -- id of the rule
-- optional attributes
  piqa_category       varchar2(10), -- category of this rule row, based on the query
  piqa_error_level    number, -- overwrite the error level based on the content of the object
  piqa_object_type    varchar2(30), -- objecttype, based on query
  piqa_error_message  varchar2(4000), -- overwrite the standard error_message for this rule
-- Information based on the query, related to the object which is checked
  object_id           number, -- object id if possible
  object_name         varchar2(100), -- name of the object
  object_value        varchar2(4000), -- value of the object itself
  object_updated_user varchar2(50), -- last update user on object
  object_updated_date date, -- last update date on object
-- apex specific parameters for buildung edit links
  apex_app_id         number, -- application where component is placed
  apex_page_id        number, -- page where component is placed
  apex_region_id      number  -- region where component is placed
);
/

PROMPT create or replace type t_plugin_qa_rules as table of t_plugin_qa_rule
create or replace type t_plugin_qa_rules as table of t_plugin_qa_rule
/

PROMPT create or replace package plugin_qa_pkg
create or replace package plugin_qa_pkg as

  c_plugin_qa_collection_name constant varchar2(30) := 'PLUGIN_QA_COLLECTION';

  -- function for returning the collection name
  function get_collection_name return varchar2;

  -- render function which is called in the apex region plugin
  -- %param p_region properties and information of region in which the plugin is used
  -- %param p_plugin properties of the plugin itself
  -- %param p_is_printer_friendly displaying the plugin printer friendly mode or not
  function render_qa_region
  (
    p_region              in apex_plugin.t_region
   ,p_plugin              in apex_plugin.t_plugin
   ,p_is_printer_friendly in boolean
  ) return apex_plugin.t_region_render_result;

  -- function is used in the apex process plugin
  -- %param p_process 
  -- %param p_plugin properties of the plugin itself
  function execute_process
  (
    p_process in apex_plugin.t_process
   ,p_plugin  in apex_plugin.t_plugin
  ) return apex_plugin.t_process_exec_result;

  -- procedure for testing purposes
  function test
  (
    p_app_id      in number
   ,p_app_page_id in number
   ,p_debug       in varchar2 default 'N'
  ) return t_plugin_qa_rules;

  -- function for inserting a new rule
  -- the function determines the next id and encapsulates the insert operation for new rules
  function insert_rule
  (
    p_piqa_name            in plugin_qa_rules.piqa_name%type
   ,p_piqa_category        in plugin_qa_rules.piqa_category%type
   ,p_piqa_object_types    in plugin_qa_rules.piqa_object_types%type
   ,p_piqa_error_message   in plugin_qa_rules.piqa_error_message%type
   ,p_piqa_comment         in plugin_qa_rules.piqa_comment%type default null
   ,p_piqa_exclude_objects in plugin_qa_rules.piqa_exclude_objects%type default null
   ,p_piqa_error_level     in plugin_qa_rules.piqa_error_level%type
   ,p_piqa_is_active       in plugin_qa_rules.piqa_is_active%type default 1
   ,p_piqa_sql             in plugin_qa_rules.piqa_sql%type
   ,p_piqa_predecessor_ids in plugin_qa_rules.piqa_predecessor_ids%type default null
   ,p_piqa_layer           in plugin_qa_rules.piqa_layer%type
  ) return plugin_qa_rules.piqa_id%type;

end plugin_qa_pkg;
/
create or replace package body plugin_qa_pkg as

  c_debugging constant boolean := false;

  -- same as t_plugin_qa_rule.piqa_object_type
  subtype t_object_type is varchar2(30);

  -- @see table comment plugin_qa_rules.piqa_object_type
  -- Values which are allowed for object_type
  c_piqa_object_type_app         constant t_object_type := 'APPLICATION';
  c_piqa_object_type_page        constant t_object_type := 'PAGE';
  c_piqa_object_type_region      constant t_object_type := 'REGION';
  c_piqa_object_type_item        constant t_object_type := 'ITEM';
  c_piqa_object_type_rpt_col     constant t_object_type := 'RPT_COL';
  c_piqa_object_type_button      constant t_object_type := 'BUTTON';
  c_piqa_object_type_computation constant t_object_type := 'COMPUTATION';
  c_piqa_object_type_validation  constant t_object_type := 'VALIDATION';
  c_piqa_object_type_process     constant t_object_type := 'PROCESS';
  c_piqa_object_type_branch      constant t_object_type := 'BRANCH';
  c_piqa_object_type_da          constant t_object_type := 'DA';
  c_piqa_object_type_da_action   constant t_object_type := 'DA_ACTION';

  -- @see table comment plugin_qa_rules.piqa_layer
  c_piqa_layer_page        constant plugin_qa_rules.piqa_layer%type := 'PAGE';
  c_piqa_layer_application constant plugin_qa_rules.piqa_layer%type := 'APPLICATION';

  -- @see table comment plugin_qa_rules.piqa_category
  c_piqa_category_apex constant plugin_qa_rules.piqa_category%type := 'APEX';

  -- @see spec
  function get_collection_name return varchar2 is
  begin
    return c_plugin_qa_collection_name;
  end get_collection_name;

  -- Edit Link to jump directly into the Application Builder
  -- Links based on the View wwv_flow_dictionary_views in column link_url
  function get_edit_link(p_plugin_qa_rule in t_plugin_qa_rule) return varchar2 is
    l_url varchar2(1000 char);
  begin
    -- Application
    if p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_app
    then
      l_url := 'f?p=4000:4001:%session%::::F4000_P1_FLOW,FB_FLOW_ID:%pk_value%,%pk_value%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.apex_app_id);
    
      -- Page
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_page
    then
      l_url := 'f?p=4000:4301:%session%::NO::F4000_P4301_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.apex_page_id);
    
      -- Page Regions
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_region
    then
      l_url := 'f?p=4000:4651:%session%:::4651,960,420:F4000_P4651_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.apex_region_id);
    
      -- Item
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_item
    then
      l_url := 'f?p=4000:4311:%session%::::F4000_P4311_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Report Column
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_rpt_col
    then
      l_url := 'f?p=4000:422:%session%:::4651,960,420,422:P422_COLUMN_ID,P420_REGION_ID,F4000_P4651_ID,P960_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%parent_pk_value%,%parent_pk_value%,%parent_pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      l_url := replace(l_url
                      ,'%parent_pk_value%'
                      ,p_plugin_qa_rule.apex_region_id);
    
      -- Button
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_button
    then
      l_url := 'f?p=4000:4314:%session%:::4314:F4000_P4314_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Computation
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_computation
    then
      l_url := 'f?p=4000:4315:%session%::::F4000_P4315_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Validation
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_validation
    then
      l_url := 'f?p=4000:4316:%session%::::F4000_P4316_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Process
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_process
    then
      l_url := 'f?p=4000:4312:%session%::NO:4312:F4000_P4312_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Branch
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_branch
    then
      l_url := 'f?p=4000:4313:%session%::::F4000_P4313_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Dynamic Action
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_da
    then
      l_url := 'f?p=4000:793:%session%::::F4000_P793_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
      -- Dynamic Action - Action
    elsif p_plugin_qa_rule.piqa_object_type = c_piqa_object_type_da_action
    then
      l_url := 'f?p=4000:591:%session%::::F4000_P591_ID,FB_FLOW_ID,FB_FLOW_PAGE_ID:%pk_value%,%application_id%,%page_id%';
    
      l_url := replace(l_url
                      ,'%pk_value%'
                      ,p_plugin_qa_rule.object_id);
    
    
    end if;
  
    l_url := replace(l_url
                    ,'%application_id%'
                    ,p_plugin_qa_rule.apex_app_id);
    l_url := replace(l_url
                    ,'%page_id%'
                    ,p_plugin_qa_rule.apex_page_id);
    l_url := replace(l_url
                    ,'%session%'
                    ,apex_application.g_edit_cookie_session_id);
  
    return l_url;
  end get_edit_link;


  -- if function returns true the a message for the predecessor is added
  -- the rule should be excluded in output
  procedure remove_message_if_predecessor
  (
    p_plugin_qa_rules     in t_plugin_qa_rules
   ,p_plugin_qa_rules_new in out t_plugin_qa_rules
  ) is
  begin
    for n in 1 .. p_plugin_qa_rules_new.count
    loop
      for i in (select 1
                from table(p_plugin_qa_rules) rules
                    ,plugin_qa_rules piqa
                where p_plugin_qa_rules_new(n).piqa_id = piqa.piqa_id
                 and piqa.piqa_predecessor_ids is not null
                 and p_plugin_qa_rules_new(n).object_id = rules.object_id
                 and p_plugin_qa_rules_new(n).piqa_object_type = rules.piqa_object_type
                 and instr(':' || piqa.piqa_predecessor_ids || ':'
                         ,':' || rules.piqa_id || ':') > 0)
      loop
        p_plugin_qa_rules_new.delete(n);
        exit;
      end loop;
    end loop;
  end remove_message_if_predecessor;

  -- run a single rule
  -- %param p_piqa_id the rule
  -- %param p_app_id application which will be tested
  -- %param p_app_page_id page which is selected
  -- %param p_plugin_qa_rules all found rules and the new result
  procedure run_rule
  (
    p_piqa_id         in plugin_qa_rules.piqa_id%type
   ,p_app_id          in apex_applications.application_id%type
   ,p_app_page_id     in apex_application_pages.page_id%type
   ,p_debug           in varchar2
   ,p_plugin_qa_rules in out t_plugin_qa_rules
  ) is
    c_unit constant varchar2(32767) := $$plsql_unit || '.run_rule';
  
    l_piqa_sql            varchar2(32767);
    l_piqa_layer          plugin_qa_rules.piqa_layer%type;
    l_plugin_qa_rules_new t_plugin_qa_rules;
  begin
    select piqa.piqa_sql
          ,piqa.piqa_layer
    into l_piqa_sql
        ,l_piqa_layer
    from plugin_qa_rules piqa
    where piqa.piqa_id = p_piqa_id;
  
    if p_debug = 'Y'
    then
      dbms_output.put_line(length(l_piqa_sql));
      dbms_output.put_line(l_piqa_sql);
    end if;
  
    if l_piqa_layer = c_piqa_layer_page
    then
      execute immediate l_piqa_sql bulk collect
        into l_plugin_qa_rules_new
        using p_piqa_id, p_app_id, p_app_page_id;
    
      if p_plugin_qa_rules is not null
      then
        p_plugin_qa_rules := p_plugin_qa_rules multiset union l_plugin_qa_rules_new;
      else
        p_plugin_qa_rules := l_plugin_qa_rules_new;
      end if;
    end if;
  
  exception
    when others then
      dbms_output.put_line(l_piqa_sql);
      raise;
  end run_rule;


  -- run all rules which are active
  procedure run_rules
  (
    p_app_id          in apex_applications.application_id%type
   ,p_app_page_id     in apex_application_pages.page_id%type
   ,p_debug           in varchar2
   ,p_plugin_qa_rules in out t_plugin_qa_rules
  ) is
  begin
    for r in (select piqa.piqa_id
              from plugin_qa_rules piqa
              where piqa.piqa_is_active = 1
              order by piqa.piqa_predecessor_ids nulls first)
    loop
      run_rule(p_piqa_id         => r.piqa_id
              ,p_app_id          => p_app_id
              ,p_app_page_id     => p_app_page_id
              ,p_debug           => p_debug
              ,p_plugin_qa_rules => p_plugin_qa_rules);
    end loop;
  end run_rules;


  procedure rules_2_collection(p_plugin_qa_rules in t_plugin_qa_rules) is
  begin
    apex_collection.create_or_truncate_collection(p_collection_name => c_plugin_qa_collection_name);
  
    -- only process when rules are returning errors
    if p_plugin_qa_rules is not null and
       p_plugin_qa_rules.count > 0
    then
    
      -- go through all messages
      for i in 1 .. p_plugin_qa_rules.count
      loop
        
        apex_collection.add_member(p_collection_name => c_plugin_qa_collection_name
                                   -- rule specific informations
                                  ,p_c001 => p_plugin_qa_rules(i).piqa_id
                                  ,p_c002 => p_plugin_qa_rules(i).piqa_category
                                  ,p_c003 => p_plugin_qa_rules(i).piqa_error_level
                                  ,p_c004 => p_plugin_qa_rules(i).piqa_object_type
                                  ,p_c005 => p_plugin_qa_rules(i).piqa_error_message
                                   -- object specific informations
                                  ,p_c020 => p_plugin_qa_rules(i).object_id
                                  ,p_c021 => p_plugin_qa_rules(i).object_name
                                  ,p_c022 => p_plugin_qa_rules(i).object_value
                                  ,p_c023 => p_plugin_qa_rules(i).object_updated_user
                                  ,p_d001 => p_plugin_qa_rules(i).object_updated_date
                                   -- apex specific parameters
                                  ,p_c040 => p_plugin_qa_rules(i).apex_app_id
                                  ,p_c041 => p_plugin_qa_rules(i).apex_page_id
                                  ,p_c042 => p_plugin_qa_rules(i).apex_region_id);
      end loop;
    end if;
  
  end rules_2_collection;


  -- HTML formated header for the region plugin
  function get_html_region_header return varchar2 is
    l_header varchar2(32767);
  begin
    l_header := '<table class="apexir_WORKSHEET_DATA">' || --
                '<tr><th> # </th>' || --
                '<th>Objecttype</th>' || --
                '<th>Objectname</th>' || --
                '<th>Message</th>' || --
                '<th>Link</th>' || --
                '</tr>';
  
    return l_header;
  end get_html_region_header;

  -- Footer for Region Plugin
  function get_html_region_footer return varchar2 is
    l_footer varchar2(32767);
  begin
    l_footer := '</table>';
  
    return l_footer;
  end get_html_region_footer;

  -- Every single line will be formated like this
  function get_html_rule_line
  (
    p_nr             in pls_integer
   ,p_plugin_qa_rule in t_plugin_qa_rule
  ) return varchar2 is
    l_line varchar2(32767);
  begin
    l_line := '<tr><td>' || p_nr || '</td>' || --
              '<td>' || p_plugin_qa_rule.piqa_object_type || '</td>' || --
              '<td>' || p_plugin_qa_rule.object_name || '</td>' || --
              '<td>' || p_plugin_qa_rule.piqa_error_message || '</td>' || --
              '<td>' || case p_plugin_qa_rule.piqa_category
                when c_piqa_category_apex then
                 '<a href="' || get_edit_link(p_plugin_qa_rule => p_plugin_qa_rule) || '">edit</a>'
                else
                 ' '
              end || '</td>' || --
              '</tr>';
    return l_line;
  end get_html_rule_line;

  -- print the rules to the region
  procedure print_result(p_plugin_qa_rules in t_plugin_qa_rules) is
  begin
    if p_plugin_qa_rules is not null and
       p_plugin_qa_rules.count > 0
    then
      -- print header for plugin region
      htp.p(get_html_region_header);
    
      -- go through all messages
      for i in 1 .. p_plugin_qa_rules.count
      loop
        htp.p(get_html_rule_line(p_nr             => i
                                ,p_plugin_qa_rule => p_plugin_qa_rules(i)));
      end loop;
    
      -- print footer
      htp.p(get_html_region_footer);
    end if;
  
  end print_result;

  -- @see spec
  function render_qa_region
  (
    p_region              in apex_plugin.t_region
   ,p_plugin              in apex_plugin.t_plugin
   ,p_is_printer_friendly in boolean
  ) return apex_plugin.t_region_render_result is
  
    l_plugin_qa_rules      t_plugin_qa_rules;
    l_region_render_result apex_plugin.t_region_render_result;
  
    -- variables
    l_app_id      apex_application_page_regions.attribute_01%type := p_region.attribute_01;
    l_app_page_id apex_application_page_regions.attribute_02%type := p_region.attribute_02;
    -- Yes => Y / No => N
    l_debug       varchar2(1)                                     := p_region.attribute_03;
  begin  
    run_rules(p_app_id          => l_app_id
             ,p_app_page_id     => l_app_page_id
             ,p_debug           => l_debug
             ,p_plugin_qa_rules => l_plugin_qa_rules);
  
    print_result(p_plugin_qa_rules => l_plugin_qa_rules);
  
    return l_region_render_result;
  end render_qa_region;


  -- @see spec
  function execute_process
  (
    p_process in apex_plugin.t_process
   ,p_plugin  in apex_plugin.t_plugin
  ) return apex_plugin.t_process_exec_result is
  
    l_plugin_qa_rules     t_plugin_qa_rules;
    l_process_exec_result apex_plugin.t_process_exec_result;
  
    -- variables
    l_app_id      apex_application_page_regions.attribute_01%type := p_process.attribute_01;
    l_app_page_id apex_application_page_regions.attribute_02%type := p_process.attribute_02;
    l_debug       apex_application_page_regions.attribute_02%type := p_process.attribute_03;    
  begin  
    run_rules(p_app_id          => l_app_id
             ,p_app_page_id     => l_app_page_id
             ,p_debug           => l_debug
             ,p_plugin_qa_rules => l_plugin_qa_rules);
  
    rules_2_collection(p_plugin_qa_rules => l_plugin_qa_rules);
  
    return l_process_exec_result;
  end execute_process;


  function test
  (
    p_app_id      in number
   ,p_app_page_id in number
   ,p_debug       in varchar2 default 'N'
  ) return t_plugin_qa_rules is
  
    l_plugin_qa_rules t_plugin_qa_rules;
  begin
    if p_app_page_id is not null
    then
      run_rules(p_app_id          => p_app_id
               ,p_app_page_id     => p_app_page_id
               ,p_debug           => p_debug
               ,p_plugin_qa_rules => l_plugin_qa_rules);
    else
      for p in (select ap.page_id
                from apex_application_pages ap
                where ap.application_id = p_app_id)
      loop
        run_rules(p_app_id          => p_app_id
                 ,p_app_page_id     => p.page_id
                 ,p_debug           => p_debug
                 ,p_plugin_qa_rules => l_plugin_qa_rules);
      end loop;
    end if;
  
    return l_plugin_qa_rules;
  end test;


  -- @see spec
  function insert_rule
  (
    p_piqa_name            in plugin_qa_rules.piqa_name%type
   ,p_piqa_category        in plugin_qa_rules.piqa_category%type
   ,p_piqa_object_types    in plugin_qa_rules.piqa_object_types%type
   ,p_piqa_error_message   in plugin_qa_rules.piqa_error_message%type
   ,p_piqa_comment         in plugin_qa_rules.piqa_comment%type default null
   ,p_piqa_exclude_objects in plugin_qa_rules.piqa_exclude_objects%type default null
   ,p_piqa_error_level     in plugin_qa_rules.piqa_error_level%type
   ,p_piqa_is_active       in plugin_qa_rules.piqa_is_active%type default 1
   ,p_piqa_sql             in plugin_qa_rules.piqa_sql%type
   ,p_piqa_predecessor_ids in plugin_qa_rules.piqa_predecessor_ids%type default null
   ,p_piqa_layer           in plugin_qa_rules.piqa_layer%type
  ) return plugin_qa_rules.piqa_id%type is
    l_piqa_id plugin_qa_rules.piqa_id%type;
  begin
    select nvl(max(piqa_id)
              ,0) + 1
    into l_piqa_id
    from plugin_qa_rules;
  
    insert into plugin_qa_rules
      (piqa_id
      ,piqa_name
      ,piqa_category
      ,piqa_object_types
      ,piqa_error_message
      ,piqa_comment
      ,piqa_exclude_objects
      ,piqa_error_level
      ,piqa_is_active
      ,piqa_sql
      ,piqa_predecessor_ids
      ,piqa_layer)
    values
      (l_piqa_id
      ,p_piqa_name
      ,p_piqa_category
      ,p_piqa_object_types
      ,p_piqa_error_message
      ,p_piqa_comment
      ,p_piqa_exclude_objects
      ,p_piqa_error_level
      ,p_piqa_is_active
      ,p_piqa_sql
      ,p_piqa_predecessor_ids
      ,p_piqa_layer);  
  
    return l_piqa_id;
  end insert_rule;

end plugin_qa_pkg;
/
