import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public class FileTransferServer {
    private static final int SERVER_PORT = 1238;
    private static final int BUFFER_SIZE = 2000;

    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(SERVER_PORT)) {
            System.out.println("TCP Server started and listening on port " + SERVER_PORT + "...");
            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("\nClient connected from: " + clientSocket.getInetAddress().getHostAddress());
                handleClient(clientSocket);
            }
        } catch (IOException e) {
            System.err.println("Could not start server: " + e.getMessage());
        }
    }

    private static void handleClient(Socket clientSocket) {
        try (
            OutputStream socketOut = clientSocket.getOutputStream();
            BufferedReader socketIn = new BufferedReader(
                new InputStreamReader(clientSocket.getInputStream(), StandardCharsets.UTF_8));
        ) {
            String fileName = socketIn.readLine();
            System.out.println("Requested file: " + fileName);
            if (fileName == null) {
                System.out.println("Client disconnected before sending filename.");
                return;
            }
            File file = new File(fileName.trim());
            if (!file.exists() || file.isDirectory()) {
                String errorMessage = "file Does not exits";
                System.out.println(errorMessage);
                socketOut.write(errorMessage.getBytes(StandardCharsets.UTF_8));
            } else {
                System.out.println("File found. Sending contents...");
                try (FileInputStream fileIn = new FileInputStream(file)) {
                    byte[] buffer = new byte[BUFFER_SIZE];
                    int bytesRead;
                    while ((bytesRead = fileIn.read(buffer)) != -1) {
                        socketOut.write(buffer, 0, bytesRead);
                    }
                    socketOut.flush();
                } catch (IOException e) {
                    System.err.println("Error reading or sending file: " + e.getMessage());
                }
            }
        } catch (IOException e) {
            System.err.println("Error processing client request: " + e.getMessage());
        } finally {
            System.out.println("Client connection closed.");
        }
    }
}