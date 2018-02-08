# powerdns
class powerdns (
  Boolean                    $authoritative         = $::powerdns::params::authoritative,
  Boolean                    $recursor              = $::powerdns::params::recursor,
  Enum['mysql','postgresql'] $backend               = $::powerdns::params::backend,
  Boolean                    $backend_install       = $::powerdns::params::backend_install,
  Boolean                    $backend_create_tables = $::powerdns::params::backend_create_tables,
  Optional[String[1]]        $db_root_password      = $::powerdns::params::db_root_password,
  String[1]                  $db_username           = $::powerdns::params::db_username,
  Optional[String[1]]        $db_password           = $::powerdns::params::db_password,
  String[1]                  $db_name               = $::powerdns::params::db_name,
  String[1]                  $db_host               = $::powerdns::params::db_host,
  Boolean                    $custom_repo           = $::powerdns::params::custom_repo,
) inherits powerdns::params {

  # Do some additional checks
  # Some parameters aren't optional if other parameters are set to true
  if $authoritative {
    if $backend_create_tables {
      assert_type(String[1], $db_root_password)
    }
    assert_type(String[1], $db_password)
  }

  # Include the required classes
  if ! $custom_repo {
    include ::powerdns::repo
  }

  if $authoritative {
    include ::powerdns::authoritative

    # Set up Hiera. Even though it's not necessary to explicitly set $type for the authoritative
    # config, it is added for clarity.
    $powerdns_auth_config = hiera('powerdns::auth::config', {})
    $powerdns_auth_defaults = { 'type' => 'authoritative' }
    create_resources(powerdns::config, $powerdns_auth_config, $powerdns_auth_defaults)
  }

  if $recursor {
    include ::powerdns::recursor

    # Set up Hiera for the recursor.
    $powerdns_recursor_config = hiera('powerdns::recursor::config', {})
    $powerdns_recursor_defaults = { 'type' => 'recursor' }
    create_resources(powerdns::config, $powerdns_recursor_config, $powerdns_recursor_defaults)
  }
}
