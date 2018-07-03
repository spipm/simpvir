

int main()
{

	// AF_INET, SOCK_DGRAM
	int sockfd = socket(2, 2, 0); 

	// sin_family = 2, sin_port = 27002 (31337), 0 = INADDR_ANY
	char rawaddress[] = { 0, 2, 0x7a, 0x69, 0, 0, 0, 0, 0, 0, 0, 0 };
	bind(sockfd, (struct sockaddr *) rawaddress, 16);

	// SOL_SOCKET, SO_RCVTIMEO
    long rawtime[]={3,0};
	setsockopt(sockfd, 65535, 4102, (char *)&rawtime, 16); 

	char buffer[128];
	recvfrom(sockfd, buffer, 128, 0, 0, 0);
 
	printf("Client Data Received: %s\n", buffer);

	close(sockfd);

}