with base as (

    select *
    from {{ ref('stg_tiktok_ads__ad_history_tmp') }}

), 

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_tiktok_ads__ad_history_tmp')),
                staging_columns=get_ad_history_columns()
            )
        }}

    from base

), 

final as (

    select  
        ad_id,
        updated_at,
        adgroup_id as ad_group_id,
        advertiser_id,
        campaign_id,
        ad_name,
        ad_text,
        app_name,
        call_to_action,
        click_tracking_url,
        impression_tracking_url,
        {{ dbt_utils.split_part('landing_page_url', "'?'", 1) }} as base_url,
        {{ dbt_utils.get_url_host('landing_page_url') }} as url_host,
        '/' || {{ dbt_utils.get_url_path('landing_page_url') }} as url_path,
        {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_source') }} as utm_source,
        {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_medium') }} as utm_medium,
        {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_campaign') }} as utm_campaign,
        {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_content') }} as utm_content,
        {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_term') }} as utm_term,
        landing_page_url,
        open_url,
        create_time,
        display_name,
        is_aco,
        is_creative_authorized,
        is_new_structure,
        opt_status,
        playable_url,
        profile_image,
        status,
        video_id,
        _fivetran_synced
    from fields

), 

most_recent as (

    select 
        *,
        row_number() over (partition by ad_id order by _fivetran_synced desc) = 1 as is_most_recent_record
    from final

)

select * from most_recent