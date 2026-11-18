import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

// Create/update only the Fiori credential from environment variables.
// Other credentials (for example git-ssh-credentials) are left untouched.
try {
    def username = System.getenv('FIORI_USERNAME')
    def password = System.getenv('FIORI_PASSWORD')

    if (!username || !password) {
        println '[init] FIORI_USERNAME / FIORI_PASSWORD not set; skipping fiori-credentials'
        return
    }

    def store = SystemCredentialsProvider.getInstance().getStore()
    def domain = Domain.global()

    store.getCredentials(domain)
        .findAll { it.id == 'fiori-credentials' }
        .each { store.removeCredentials(domain, it) }

    store.addCredentials(
        domain,
        new UsernamePasswordCredentialsImpl(
            CredentialsScope.GLOBAL,
            'fiori-credentials',
            'SAP Fiori trial account',
            username,
            password
        )
    )
    SystemCredentialsProvider.getInstance().save()
    println '[init] fiori-credentials configured from environment'
} catch (Exception e) {
    println "[init] Failed to configure fiori-credentials: ${e}"
}
