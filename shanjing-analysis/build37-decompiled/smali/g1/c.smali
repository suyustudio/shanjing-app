.class final Lg1/c;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lf1/b;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Lf1/b<",
        "Ld1/c;",
        ">;"
    }
.end annotation


# instance fields
.field private final a:Ljava/lang/CharSequence;

.field private final b:I

.field private final c:I

.field private final d:La1/p;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "La1/p<",
            "Ljava/lang/CharSequence;",
            "Ljava/lang/Integer;",
            "Lq0/j<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;>;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Ljava/lang/CharSequence;IILa1/p;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/CharSequence;",
            "II",
            "La1/p<",
            "-",
            "Ljava/lang/CharSequence;",
            "-",
            "Ljava/lang/Integer;",
            "Lq0/j<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;>;)V"
        }
    .end annotation

    const-string v0, "input"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "getNextMatch"

    invoke-static {p4, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lg1/c;->a:Ljava/lang/CharSequence;

    iput p2, p0, Lg1/c;->b:I

    iput p3, p0, Lg1/c;->c:I

    iput-object p4, p0, Lg1/c;->d:La1/p;

    return-void
.end method

.method public static final synthetic a(Lg1/c;)La1/p;
    .locals 0

    iget-object p0, p0, Lg1/c;->d:La1/p;

    return-object p0
.end method

.method public static final synthetic b(Lg1/c;)Ljava/lang/CharSequence;
    .locals 0

    iget-object p0, p0, Lg1/c;->a:Ljava/lang/CharSequence;

    return-object p0
.end method

.method public static final synthetic c(Lg1/c;)I
    .locals 0

    iget p0, p0, Lg1/c;->c:I

    return p0
.end method

.method public static final synthetic d(Lg1/c;)I
    .locals 0

    iget p0, p0, Lg1/c;->b:I

    return p0
.end method


# virtual methods
.method public iterator()Ljava/util/Iterator;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Iterator<",
            "Ld1/c;",
            ">;"
        }
    .end annotation

    new-instance v0, Lg1/c$a;

    invoke-direct {v0, p0}, Lg1/c$a;-><init>(Lg1/c;)V

    return-object v0
.end method
