node('docker') {

    def dispatchImage
    stage('Prepare Image') {
        dispatchImage = docker.build('dispatch')
    }

    stage('build & deploy') {
        def options = """
        --privileged 
        -v `pwd`:/app 
        -v `$HOME/.m2`:/home/jenkins/.m2 
        -v `$HOME/.gitconfig`:/home/jenkins/.gitconfig
        -v `$HOME/ld-config`:/home/jenkins/ld-config
        """
        
        dispatchImage.inside(options) {
            sh 'mvn deploy'
        }
    }
}