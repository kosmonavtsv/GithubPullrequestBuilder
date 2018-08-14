class GitCommit {
    [string] $Title
    [string] $Description
    GitCommit($Title, $Description) {
        if ($Title) {
            $this.Title = $Title.Trim()
        }
        if ($Description) {
            $this.Description = $Description.Trim()
        }
    }
}
