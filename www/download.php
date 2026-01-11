<?php
$file = __DIR__ . '/scripts/wifi_sensor.ps1';

if (!file_exists($file)) {
    http_response_code(404);
    exit('Arquivo não encontrado');
}

header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="wifi_sensor.ps1"');
header('Content-Length: ' . filesize($file));

readfile($file);
exit;

?>