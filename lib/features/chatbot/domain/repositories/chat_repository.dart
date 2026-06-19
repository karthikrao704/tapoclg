import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';
import 'package:tapovana_mobile_app/features/more/repositories/more_repository.dart';

class ChatRepository {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  ChatRepository();

  Future<void> _initModel() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('Gemini API Key not found in .env');
    }

    String contextString = "";
    try {
      final serviceRepo = ServiceRepository();
      final moreRepo = MoreRepository();

      final services = await serviceRepo.getAllServices();
      final packages = await moreRepo.getVedicPrograms();
      final workshops = await moreRepo.getWorkshops();
      final blogs = await moreRepo.getBlogs();

      final serviceNames = services.map((s) => s.name).join(', ');
      final packageNames = packages.map((p) => p.title).join(', ');
      final workshopNames = workshops.map((w) => w.title).join(', ');
      final blogNames = blogs.map((b) => b.title).join(', ');

      contextString = '''
Available Services: $serviceNames
Available Vedic Packages: $packageNames
Upcoming Workshops: $workshopNames
Wellness Blogs: $blogNames

CRITICAL RULES:
1. ONLY recommend services, packages, workshops, or blogs explicitly listed above.
2. DO NOT invent, hallucinate, or suggest any dummy names or services that are not in the provided lists above.
''';
    } catch (e) {
      debugPrint("Could not load context for Chatbot: $e");
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('''You are Tapo, a personal wellness guide at Tapovana. 
Keep your answers helpful, concise, and focused on wellness, yoga, ayurveda, and the services explicitly offered at Tapovana.

$contextString'''),
    );
    _chatSession = _model!.startChat();
  }

  Future<String> sendMessage(String message) async {
    if (_chatSession == null) {
      await _initModel();
    }
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'I am sorry, I could not understand that.';
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
