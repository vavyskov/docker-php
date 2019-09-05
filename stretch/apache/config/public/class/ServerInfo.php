<?php
// ServerInfo.php

class ServerInfo
{
    /**
     * Not available (N/A)
     * @return string
     */
    private function notAvailable()
    {
        return "<img src='asset/times.svg' alt='N/A' height='16' width='16' class='align-middle'>";
    }

    /**
     * Debian
     * @return string
     */
    private function debian()
    {
        if (exec('cat /etc/os-release')) {
            return exec('cat /etc/os-release | head -1 | cut -d\" -f2 | cut -d" " -f1,3,4');
        } else {
            return $this->notAvailable();
        }
    }

    /**
     * SQLite
     * @return string
     */
    private function sqlite()
    {
        if (class_exists('SQLite3')) {
            $sql_db = new PDO('sqlite::memory:');
            return $sql_db->query('select sqlite_version()')->fetch()[0];
        } else {
            //throw new Exception('SQLite not installed');
            return $this->notAvailable();
        }
    }

    /**
     * Xdebug
     * @return string
     */
    private function xdebug()
    {
        return phpversion('xdebug') ? phpversion('xdebug') : $this->notAvailable();
    }

    /**
     * Memcached
     * @return bool|string
     */
    function memcached()
    {
        if (class_exists('Memcache')) {
            $memcache = new Memcache;
            if ($memcache->getVersion() === false) {
                //throw new Exception('Please, verify the Memcache configuration');
                return $this->notAvailable();
            } else {
                return $memcache->getVersion();
            }
        } else {
            return $this->notAvailable();
        }
    }

    function swVersion()
    {
        // Command, Filter, Alternative, Position, Delimiter
        $sofware = array(
            'Linux' => [
                'version' => 'lsb_release -d 2>&1 | cut -d: -f2 | cut -d" " -f1,3,4',
                'alternative' => $this->debian(),
            ],
            'Apache' => [
                'version' => 'apache2 -v 2>&1 | head -1 | cut -d/ -f2 | cut -d" " -f1',
            ],
            'PHP' => [
                'version' => 'php -v 2>&1 | head -1 | cut -d" " -f2 | cut -d- -f1',
            ],
            'ICU (php-intl)' => [
                'version' => 'php -i | grep "ICU version" | cut -d" " -f4',
            ],
            'SQLite' => [
                'version' => 'sqlite3 --version 2>/dev/null | cut -d" " -f1',
                'alternative' => $this->sqlite(),
            ],
            'MySQL' => [
                'version' => 'mysql -V 2>/dev/null | cut -d" " -f6 | cut -d, -f1',
            ],
            'PostgreSQL' => [
                'version' => 'psql -V 2>/dev/null | cut -d" " -f3',
            ],
            'MongoDB' => [
                'version' => 'mongod --version 2>/dev/null | head -1 | cut -d" " -f3 | cut -dv -f2',
            ],
            'SSH' => [
                'version' => 'ssh -V 2>&1 | cut -d" " -f1 | cut -d_ -f2',
            ],
            'Git' => [
                'version' => 'git --version 2>&1 | cut -d" " -f3',
            ],
            'Composer' => [
                'prefix' => putenv("COMPOSER_HOME=/home/vagrant/.composer"),
                'version' => 'composer --version 2>&1 | cut -d" " -f3',
            ],
            'Node.js' => [
                'version' => 'nodejs -v 2>/dev/null | cut -dv -f2',
            ],
            'Yarn' => [
                'version' => 'yarn -v 2>/dev/null',
            ],
            'Image Magick' => [
                'version' => 'convert --version 2>/dev/null | head -1 | cut -d" " -f3',
            ],
            /*'OptiPNG' => [
                'version' => 'optipng --version 2>/dev/null | head -1 | cut -d" " -f3',
            ],*/
            /*'GIFsicle' => [
                'version' => 'gifsicle --version 2>/dev/null | head -1 | cut -d" " -f3',
            ],*/
            'Xdebug' => [
                'alternative' => $this->xdebug(),
            ],
            /*'Memcached' => [
                'version' => 'memcached -V | cut -d" " -f2',
                'alternative' => $this->memcached(),
            ],*/
        );
     $data = array();
        foreach ($sofware as $key => $value) {
            // Prefix
            if (isset($value['prefix']))
            {
                $value['prefix'];
            }

            // Version
            if (isset($value['version']) && exec($value['version']))
            {
                $version = exec($value['version']);
            }
            elseif (isset($value['alternative']))
            {
                $version = $value['alternative'];
            }
            else
            {
                $version = $this->notAvailable();
            }

            // Data
            $data += [$key => $version];
        }

        // Template
        extract($data);
        require ("template/software.phtml");
    }







    /**
     * PHP Extensions
     * @return string
     *
     * php -m|grep gd
     * php -m|grep imagick
     * php -m|grep mbstring
     */
    function phpExtension() {
        $php_extension = array(
            "Graphics Drawing (GD)" => "gd",
            "Image Magick" => "imagick",
            "Multibyte String" => "mbstring",
            "OPcache" => "Zend OPcache",
            "XML" => "xml",
            "cURL" => "curl",
            "Zip" => "zip",
            "APCu" => "apcu",
            "PECL upload progress" => "uploadprogress",
            "LDAP" => "ldap",
            //"SQLite" => "sqlite3",
            "SQLite (PDO)" => "pdo_sqlite",
            //"MySQLi" => "mysqli",
            "MySQL (PDO)" => "pdo_mysql",
            //"PostgreSQL" => "pgsql",
            "PostgreSQL (PDO)" => "pdo_pgsql",
            //"Memcache" => "memcache",
            //"Memcached" => "memcached",
        );
        $data = array();
        foreach ($php_extension as $key => $value) {
            (extension_loaded($value) ? $img = ['file' => 'check.svg', 'alt' => 'OK'] : $img = [ 'file' => 'times.svg', 'alt' => 'N/A']);
            $state = '<img src="asset/' . $img['file'] . '" alt="' . $img['alt'] . '" height="16" width="16" class="align-middle">';
            $data += [$key => $state];
        }
        extract($data);
        require ("template/php-extension.phtml");
    }

    /**
     * External access
     *//*
    function externalAccess() {
        $_SERVER['SERVER_ADDR'] .' | '.
        gethostbyname($_SERVER['SERVER_NAME']) .' | '.
        $_SERVER['SERVER_NAME'] .' | '.
        gethostname() .' | '.
        gethostbyaddr($_SERVER['REMOTE_ADDR']);
    }*/
}