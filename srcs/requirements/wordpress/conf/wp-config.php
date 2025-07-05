<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'relvan' );

/** Database password */
define( 'DB_PASSWORD', '12345' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'LS~KGw^}/!:=&;N=bV.+DkwE>vQ[`,!B%miowMDrag4L6u[}+&A5w<#u--|ESsxP');
define('SECURE_AUTH_KEY',  '}*inLYPz#L{<++n)*E-xe|X1I?}Z@}}IQ&nfzy@w76b, ]w,E9]%HKq=NJ,Vt3V/');
define('LOGGED_IN_KEY',    ']gJKu9G`,)q6#uY>yJJc#QTv8c;RP)Gk61|<no|;0K+Z0R?OKZ`I~iHU8vei+ipk');
define('NONCE_KEY',        ')T@C+p|XquAC{8*JW-;#;?}EL=+3Ar?aA1|#D2wwTE+fn%7*c1tSox@b?eWk?(~0');
define('AUTH_SALT',        '(33NW sl-(gS@H7b<LwFiv#>nAz8vQ6s[1<.r-.@e.K^Pc816QPK}LKdLzBE%dq{');
define('SECURE_AUTH_SALT', 'E4B-$?#P|1:]IYJr QBMNb- g54lbtFMX~$<$y7m+Z<Oq3X`#}/x;0?PV?stIz(g');
define('LOGGED_IN_SALT',   '<da,!Bvlk4Z-yLiph~y!9TY2m.!Pox)M>}:A[PRCfuoX-@.R-G-cF (j.2Xqx:&N');
define('NONCE_SALT',       'o3XnyL5?A#2[VplBlfD|@3,FeTkF5]+5W T]<3bVU+A^1|Cd7J-dS~}!Ct0Y<fj}');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';