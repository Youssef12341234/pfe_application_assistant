Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force -Path out | Out-Null

function Build-Pdf($template, $values, $outFile) {
    $tex = Get-Content $template -Raw -Encoding UTF8
    foreach ($k in $values.Keys) { $tex = $tex.Replace("@@$k@@", $values[$k]) }
    $body = @{ tex = $tex } | ConvertTo-Json
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    try {
        Invoke-WebRequest -Uri http://localhost:8000/compile -Method Post -ContentType "application/json; charset=utf-8" -Body $bytes -OutFile $outFile
        Write-Host "OK : $outFile"
    } catch {
        Write-Host "ERREUR :" $_.ErrorDetails.Message
    }
}

$cv = @{
    NAME = 'Test Etudiant'
    EMAIL = 'test@example.com'
    PHONE = '+212 6 00 00 00 00'
    LINKEDIN = 'linkedin.com/in/test'
    PORTFOLIO = 'portfolio.example.com'
    SUMMARY = 'Etudiant en ingenierie Data Science et IA, en recherche de stage PFE de 6 mois.'
    EDUCATION = '\entry{Cycle ingenieur Data Science et IA}{EMSI Rabat}{2022 -- 2027}'
    EXPERIENCES = '\entry{Stagiaire Data}{Entreprise Test}{Juil. 2026 -- Aout 2026}\begin{itemize}\item Exemple de realisation 1\item Exemple de realisation 2\end{itemize}'
    PROJECTS = '\entry{Projet exemple}{Python, n8n}{2026}\begin{itemize}\item Description du projet\end{itemize}'
    SKILLS = '\textbf{Langages :} Python, SQL \\ \textbf{Outils :} n8n, Docker, Power BI'
    CERTIFICATIONS = 'Certification exemple'
    LANGUAGES = 'Francais, Anglais'
}

$letter = @{
    NAME = 'Test Etudiant'
    EMAIL = 'test@example.com'
    PHONE = '+212 6 00 00 00 00'
    CITY = 'Rabat'
    DATE = '7 novembre 2026'
    COMPANY = 'Entreprise Test'
    SUBJECT = 'Candidature au stage PFE 2027 en Data et IA'
    BODY = ('Premier paragraphe de test.' + "`n`n" + 'Deuxieme paragraphe de test.')
}

Build-Pdf "templates\cv_template.tex" $cv "out\cv_test.pdf"
Build-Pdf "templates\letter_template.tex" $letter "out\letter_test.pdf"

Start-Process out\cv_test.pdf
Start-Process out\letter_test.pdf