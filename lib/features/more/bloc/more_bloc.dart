import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/more_models.dart';
import '../repositories/more_repository.dart';

part 'more_event.dart';
part 'more_state.dart';

class MoreBloc extends Bloc<MoreEvent, MoreState> {
  final MoreRepository _moreRepository;

  MoreBloc({MoreRepository? moreRepository})
      : _moreRepository = moreRepository ?? MoreRepository(),
        super(const MoreState()) {
    on<LoadMoreContent>(_onLoadMoreContent);
    on<RefreshMoreContent>(_onRefreshMoreContent);
  }

  Future<void> _onLoadMoreContent(
    LoadMoreContent event,
    Emitter<MoreState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final workshops = await _moreRepository.getWorkshops();

      emit(
        state.copyWith(
          isLoading: false,
          workshops: workshops,
          vedicPackages: const [
            VedicPackage(
              title: 'Prakruthi\nJourney',
              subtitle: '14 Day Detox',
              imagePath: 'assets/images/nature1.png',
              description: 'Embark on a transformational 14-day detoxification process. This program restores your body\'s natural state by eliminating accumulated toxins through personalized Ayurvedic therapies, herbal supplements, and dietary adjustments.',
              duration: '14 Days',
              price: '₹14,999',
              originalPrice: '₹22,000',
              benefits: [
                'Total Body Toxins Flush',
                'Improved Digestion & Absorption',
                'Enhanced Skin Radiance',
                'Boosted Metabolic Rate'
              ],
              whatsIncluded: [
                'Daily Ayurvedic Therapies (90 mins)',
                'Customized Sattvic Meals & Herbs',
                'Daily Yoga & Pranayama Sessions',
                '2 Doctor Consultations & Pulse Analysis'
              ],
              tags: ['DETOX', 'AYURVEDA', 'RENEWAL'],
            ),
            VedicPackage(
              title: 'Sattva Retreat',
              subtitle: 'Purity & Mindset',
              imagePath: 'assets/images/nature2.png',
              description: 'Cultivate purity of mind and body. This retreat is designed to calm an overactive nervous system, clear mental clutter, and help you transition into a state of Sattva—peace, harmony, and consciousness.',
              duration: '7 Days',
              price: '₹9,999',
              originalPrice: '₹15,000',
              benefits: [
                'Deep Nervous System Relaxation',
                'Mental Clarity & Alertness',
                'Better Sleep Quality',
                'Emotional Equilibrium'
              ],
              whatsIncluded: [
                'Shirodhara & Head Therapies (60 mins)',
                'Guided Mindfulness & Sound Healing',
                'Personalized Sattvic Nutrition Guide',
                'Private Spiritual & Wellness Mentorship'
              ],
              tags: ['MINDFULNESS', 'RETREAT', 'PEACE'],
            ),
            VedicPackage(
              title: 'Tejas Balance',
              subtitle: 'Agni & Metabolism',
              imagePath: 'assets/images/nature1.png',
              description: 'Reignite your inner fire (Agni). This package focuses on balancing your digestive metabolic rate and correcting metabolic imbalances that cause fatigue, weight fluctuations, and sluggishness.',
              duration: '10 Days',
              price: '₹11,999',
              originalPrice: '₹18,000',
              benefits: [
                'Balanced Digestive Strength (Agni)',
                'Healthy Weight Management',
                'Increased Physical Energy',
                'Reduced Systemic Inflammation'
              ],
              whatsIncluded: [
                'Udvartana (Herbal Powder Massage)',
                'Custom Ayurvedic Digestive Herbs',
                'Dynamic Metabolic Yoga Workouts',
                'Ongoing Dietary Guidance & Coaching'
              ],
              tags: ['METABOLISM', 'ENERGY', 'BALANCE'],
            ),
            VedicPackage(
              title: 'Ojas Vitality',
              subtitle: 'Immunity & Strength',
              imagePath: 'assets/images/nature2.png',
              description: 'Build your core immunity (Ojas) and physical vigor. This package utilizes traditional Rasayana (rejuvenation) herbs, strengthening therapies, and energy-conservation techniques to build long-term disease resistance.',
              duration: '21 Days',
              price: '₹19,999',
              originalPrice: '₹28,000',
              benefits: [
                'Strengthened Immune Response',
                'Enhanced Muscle Tone & Vigor',
                'Cellular Rejuvenation',
                'Long-lasting Longevity Support'
              ],
              whatsIncluded: [
                'Pizhichil Warm Oil Therapy (90 mins)',
                'Premium Rasayana Herbal Jam & Tonics',
                'Vigorous Hatha Yoga & Breathwork',
                'Comprehensive Post-Retreat Wellness Plan'
              ],
              tags: ['IMMUNITY', 'STRENGTH', 'VITALITY'],
            ),
          ],
          blogPosts: const [
            WellnessBlogPost(
              category: 'NATURAL HEALING',
              title: 'The Power of Sandalwood',
              imagePath: 'assets/images/sandalwood.png',
              content: 'Sandalwood (Chandana) is one of the most revered ingredients in Ayurvedic skincare and cooling therapy. Known for its distinct woody aroma and cooling properties (virya), it has been used for centuries to balance Pitta dosha and soothe skin irritation.\n\n### Therapeutic Benefits\n1. **Soothing Inflammations**: Application of sandalwood paste instantly cools down sunburns, redness, and inflammatory skin conditions.\n2. **Mental Calmness**: The aromatherapy of sandalwood promotes alpha wave brain activity, reducing stress and anxiety.\n3. **Natural Astringent**: It tightens pores, keeps the skin firm, and minimizes blemishes.\n\n### Simple Home Remedies\nTo treat acne or heat rashes, mix 1 teaspoon of organic sandalwood powder with enough rosewater to form a paste. Apply it to the face or affected areas and wash off after 15 minutes with cool water.',
              author: 'Dr. Ananya Rao',
              date: 'May 15, 2026',
              readTime: '4 min read',
            ),
            WellnessBlogPost(
              category: 'ROUTINES',
              title: 'Morning Rituals',
              imagePath: 'assets/images/morningritual.png',
              content: 'How you begin your day sets the tone for your mind, energy, and digestion. In Ayurveda, the morning routine is called Dinacharya, which is designed to synchronize the body with nature\'s rhythms.\n\n### Core Practices of Dinacharya\n1. **Wake up before Sunrise (Brahma Muhurta)**: Waking up around 5:00 AM matches the Vata energy of lightness and clarity, giving you a fresh start.\n2. **Tongue Scraping (Jihwa Prakshalana)**: Use a copper scraper to remove the white coating (ama or toxins) from your tongue every morning. This improves taste perception and stimulates digestion.\n3. **Oil Pulling (Gandusha)**: Swishing warm sesame or coconut oil in your mouth for 5-10 minutes strengthens the gums, whitens teeth, and extracts oral bacteria.\n4. **Warm Water Intake**: Drinking a glass of warm water stimulates bowel movements (Agni) and cleanses the digestive tract.',
              author: 'Acharya Madhavan',
              date: 'May 20, 2026',
              readTime: '5 min read',
            ),
            WellnessBlogPost(
              category: 'HOLISTIC CARE',
              title: 'Benefits of Neem',
              imagePath: 'assets/images/sandalwood.png',
              content: 'Neem (Azadirachta indica), also known as "Arishta" in Sanskrit meaning perfect and imperishable, is Ayurveda\'s ultimate purifying herb. Its intensely bitter taste and cooling property make it a powerful cleanser for the blood and skin.\n\n### Key Benefits of Neem\n1. **Blood Purification**: Neem support healthy liver function and detoxifies the blood, helping to cure acne, eczema, and psoriasis from the root.\n2. **Anti-microbial and Anti-fungal**: Neem leaves contain nimbin and nimbidin, which destroy bacteria and fungal pathogens on contact.\n3. **Oral Health**: Chewing on neem twigs has been a traditional practice to prevent cavities, plaque buildup, and gingivitis.\n\n### How to use Neem\nFor skin care, boil neem leaves in water, strain, and use the water for facial cleansing. For blood purification, consult an Ayurvedic doctor before consuming neem.',
              author: 'Dr. Vaidya Raman',
              date: 'May 25, 2026',
              readTime: '5 min read',
            ),
            WellnessBlogPost(
              category: 'DIET & NUTRITION',
              title: 'Sattvic Diet Guide',
              imagePath: 'assets/images/nature2.png',
              content: 'A Sattvic diet is a high-prana diet designed to promote mental clarity, physical health, and longevity. The word "Sattva" stands for purity, peace, and harmony. Sattvic food is fresh, light, nutritious, and cooked with love.\n\n### Core Principles of Sattvic Nutrition\n1. **Freshness is Key**: Food should be consumed within 3-4 hours of cooking. Frozen, canned, or reheated foods are considered Tamasic (devoid of life-force).\n2. **Whole Foods**: Organic fresh fruits, seasonal vegetables, whole grains (like red rice, quinoa, and oats), and raw nuts form the foundation.\n3. **Ahimsa & Peace**: Sattvic food is completely vegetarian and prepared in a calm, peaceful state of mind.\n4. **Avoid Stimulants**: Highly spicy, salty, or sour foods, as well as onions, garlic, coffee, and alcohol are avoided as they aggravate Rajas (restlessness).\n\n### Everyday Sattvic Choices\nStart your day with fresh seasonal fruits or soaked almonds. Choose warm kitchari (mung dal and rice) cooked with ghee and digestive spices for lunch.',
              author: 'Nutritionist Priya Sen',
              date: 'June 01, 2026',
              readTime: '6 min read',
            ),
          ],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load content: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshMoreContent(
    RefreshMoreContent event,
    Emitter<MoreState> emit,
  ) async {
    add(const LoadMoreContent());
  }
}
