#!/usr/bin/perl -w

use AptPkg::Config '$_config';
use AptPkg::System '$_system';
use AptPkg::Source;
use AptPkg::Cache;
$_config->init();
$_system = $_config->system();

