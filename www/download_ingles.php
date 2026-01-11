<?php
$file = __DIR__ . '/scripts/wifi_sensor_ingles.ps1';

if (!file_exists($file)) {
    http_response_code(404);
    exit('File not found');
}

header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="wifi_sensor_ingles.ps1"');
header('Content-Length: ' . filesize($file));

readfile($file);
exit;

?>