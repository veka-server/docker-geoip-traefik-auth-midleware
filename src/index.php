<?php
# La bdd est dispo ici : https://ipinfo.io/dashboard/downloads version lite

#Récupère le paramètre pays
$pays = strtoupper($_GET['pays'] ?? '');

// Vérifie que le pays est 2 caractères alphabétiques (ISO 3166-1 alpha-2)
if (!preg_match('/^[A-Z]{2}$/', $pays)) {
    header("Content-Type: text/plain");
    http_response_code(403);
    echo "Forbidden : Le pays doit être un code ISO 3166-1 alpha-2 valide (2 lettres majuscules).";
    die();
}

// IP du client
$ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

// Si X-Forwarded-For contient plusieurs IPs, prends la première (IP du client)
$ip = explode(',', $ip)[0];

// Fichier de cache
$cacheFile = '/tmp/geoip-cache-'.$pays.'.json';
$maxCacheSize = 500 * 1024; // 500 Ko
$maxCacheAge = 1 * 60 * 60; // 1 heure

// Vérifie l’âge du fichier et supprime si trop vieux
if (file_exists($cacheFile) && (time() - filemtime($cacheFile)) > $maxCacheAge) {
    unlink($cacheFile);
}

// Charge le cache existant
$cache = [];
if (file_exists($cacheFile) && filesize($cacheFile) <= $maxCacheSize) {
    $cache = json_decode(file_get_contents($cacheFile), true) ?: [];
} elseif (file_exists($cacheFile) && filesize($cacheFile) > $maxCacheSize) {
    // Si trop gros, supprime le cache
    unlink($cacheFile);
}

$geoipDbFile = './location.mmdb';

try {

    if(!isset($cache[$ip])) {
        
        try {
            require_once 'vendor/autoload.php';
            $dbReader = new MaxMind\Db\Reader($geoipDbFile);
            $p = $dbReader->get($ip);
            $country_code = $p[country_code];
        }catch(){
            $country_code = 'country unknown';
        }
        
        // Autorise seulement les IP du pays
        if (country_code !== $pays) {
            throw new \Exception("Mauvais pays", 1);
        }

    }
    if( $cache[$ip] === false) {
        throw new \Exception("Mauvais pays from cache", 1);
    }

    $statut_cache = true;
            
    header("Content-Type: text/plain");
    http_response_code(200);

} catch (\Exception $e) {
    // Si échec de lookup, on bloque
    http_response_code(403);

    echo "Forbidden : your IP is ".($ip ?? unknown).' '.$country_code.' ';
#    echo $e->getMessage();

    $statut_cache = false;
}

// Sauvegarde le cache (création ou mise à jour)
$cache[$ip] = $statut_cache;
file_put_contents($cacheFile, json_encode($cache));
die();